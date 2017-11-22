pragma solidity ^0.4.16;

 import "https://github.com/DecentralizedDerivatives/Oracles/Oracle.sol";
 import "https://github.com/DecentralizedDerivatives/Deriveth/SafeMath.sol";
 
//This is the swap contract itself
contract Swap {

  using SafeMath for uint256;
  enum SwapState {created,open,started,ready,ended}
  SwapState public currentState; //state of the swap, open can be entered by opposing party
  address public long_party;//Party going long the rate
  address public short_party;//Party short the rate
  uint public notional;//This is the amount that the change will be calculated on.  10% change in rate on 100 Ether notional is a 10 Ether change
  uint public lmargin;//The amount the long party puts as collateral (max he can lose, most short party can gain)
  uint public smargin;//The amount the short party puts as collateral (max he can lose, most long party can gain)
  address public oracleID;//The Oracle address (check for list at www.github.com/DecentralizedDerivatives/Oracles)
  uint public startDate;//Start Date of Swap - is the hex representation of the date variable in YYYYMMDD
  uint public endDate;//End Date of Swap - is the hex representation of the date variable in YYYYMMDD
  address public creator;//The Factory it was created from
  bool public cancel_long;//The cancel variable.  If 0, no parties want to cancel.   Once Swap is started, both parties can cancel.  If cancel =1, other party is trying to cancel
  bool public cancel_short;
  bool public paid_short;
  bool public paid_long;
  uint public share_long;
  uint public share_short;
  uint public l_premium;/* in wei*/
  uint public s_premium;/* in wei*/
  address party;
  bool long;
  struct DocumentStruct{bytes32 name; uint value;}
  mapping(address => uint256) balances;

modifier onlyState(SwapState expectedState) {require(expectedState == currentState);_;}

Oracle oracle;

  //this base function is run by the Factory
  function Swap(address _oracleID, address _cpty1, address _creator) public{
      oracle = Oracle(_oracleID);
      oracleID = _oracleID;
      creator = _creator;
      party = _cpty1;
      currentState = SwapState.created;
    
  }


  //this function is where you enter the details of your swap.  
  //The Eligble Contract Participant variable (ECP) verifies that the party self identifies as eligible to enter into a swap based upon their jurisdiction
  //Be sure to send your collateral (margin) while entering the details.
  function CreateSwap(bool ECP, uint _margin, uint _margin2, uint _notional, bool _long, uint _startDate, uint _endDate, uint256 _l_premium, uint256 _s_premium) public onlyState(SwapState.created) payable {
      require(ECP);
      require (msg.sender == party);
      require(_endDate > _startDate);
      notional = _notional.mul(1000000000000000000);
      long = _long;
      l_premium = _l_premium;
      s_premium = _s_premium;
      if (long){long_party = msg.sender;
        lmargin = _margin.mul(1000000000000000000);
        smargin = _margin2.mul(1000000000000000000);
        require(msg.value == l_premium.add(lmargin));
      }

      else {short_party = msg.sender;
        smargin = _margin.mul(1000000000000000000);
        lmargin = _margin2.mul(1000000000000000000);
        require(msg.value == s_premium.add(smargin));
      }
      currentState = SwapState.open;
      endDate = _endDate;
      startDate = _startDate;
  }

  //This function is for those entering the swap.  
  //Needing to enter the details of the swap a second time ensures that your counterparty cannot modify the terms right before you enter the swap. 
  //Note you do not need to enter your collateral as a variable, however it must be submitted with the contract
  function EnterSwap(bool ECP, uint _margin, uint _notional, bool _long, uint _startDate, uint _endDate, uint256 _l_premium, uint256 _s_premium) public onlyState(SwapState.open) payable returns (bool) {
      require(ECP);
      require(_long != long && notional == _notional.mul(1000000000000000000) && _startDate == startDate && _endDate == endDate);
      if (long) {short_party = msg.sender;
      require(msg.value >= s_premium + smargin);
      require(lmargin + l_premium >= _l_premium.add(_margin.mul(1000000000000000000)));
      }
      else {long_party = msg.sender;
      require(msg.value >= l_premium + lmargin);
      require (smargin + s_premium >= _s_premium.add(_margin.mul(1000000000000000000)));
      }
      currentState = SwapState.started;
      return true;
  }
  

//This function calculates the payout of the swap.  Note that the value of the underlying cannot reach zero, but get within .001 * the precision of the Oracle
    function Calculate() public onlyState(SwapState.started){
    uint p1= RetrieveData(endDate).mul(1000).div(RetrieveData(startDate));
    if (p1 == 1000){
            share_long = lmargin;
            share_short = smargin;
        }
        else if (p1<1000){
              if(notional.mul(1000 - p1).div(1000)>lmargin){share_long = s_premium; share_short =this.balance - s_premium;}
              else {
                share_short = l_premium.add(smargin).add(((1000 - p1)).mul(notional).div(1000));
                share_long = this.balance -  share_short;
              }
          }
          
        else if (p1 > 1000){
               if(notional.mul(p1-1000).div(1000) > smargin){share_short = l_premium; share_long =this.balance - l_premium;}
               else {
                  share_long = s_premium.add(lmargin).add((p1 - 1000).mul(notional).div(1000));
                  share_short = this.balance - share_long;
               }
          }
          
      currentState = SwapState.ready;
  }
  

//Once calcualted, this function allows each party to withdraw their share of the collateral.
  function PaySwap() public onlyState(SwapState.ready){
  if (msg.sender == long_party && paid_long == false){
        paid_long = true;
        long_party.transfer(share_long);
        cancel_long = false;
    }
    else if (msg.sender == short_party && paid_short == false){
        paid_short = true;
        short_party.transfer(share_short);
        cancel_short = false;
    }
    if (paid_long && paid_short){currentState = SwapState.ended;}
  }

//This function allows both parties to exit.  If only the creator has entered the swap, then the swap can be cancelled and the details modified
//Once two parties enter the swap, the contract is null after cancelled

  function Exit() public {
    require(currentState != SwapState.ended);
    require(currentState != SwapState.created);
    if (currentState == SwapState.open && msg.sender == party) {
        delete lmargin;
        delete smargin;
        delete notional;
        delete long;
        delete startDate;
        delete endDate;
        delete short_party;
        delete long_party;
        delete s_premium;
        delete l_premium;
        currentState = SwapState.created;
        msg.sender.transfer(this.balance);
    }

  else{
    if (msg.sender == long_party && paid_long == false){cancel_long = true;}
    if (msg.sender == short_party && paid_short == false){cancel_short = true;}
    if (cancel_long && cancel_short){
        short_party.transfer(smargin + s_premium);
        long_party.transfer(lmargin + l_premium);
        currentState = SwapState.ended;
      }
    }
  }

//If you want to check if the Calculate function can be run, enter the hex of the date in the RetrieveData field and see if it returns a non-zero value
  function RetrieveData(uint _date) public constant returns (uint data) {
    uint value = oracle.oracle_values(_date);
    return value;
  }

}
