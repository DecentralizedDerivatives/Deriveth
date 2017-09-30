pragma solidity ^0.4.16;

 import "https://github.com/DecentralizedDerivatives/Deriveth/Oracle.sol";
 import "https://github.com/DecentralizedDerivatives/Deriveth/Sf.sol";
//This is the swap contract itself
contract Swap {
  enum SwapState {created,open,started,ready,ended}
  SwapState public currentState; //state of the swap, open can be entered by opposing party
  address public long_party;//Party going long the rate
  address public short_party;//Party short the rate
  uint public notional;//This is the amount that the change will be calculated on.  10% change in rate on 100 Ether notional is a 10 Ether change
  uint public lmargin;//The amount the long party puts as collateral (max he can lose, most short party can gain)
  uint public smargin;//The amount the short party puts as collateral (max he can lose, most long party can gain)
  address public oracleID;//The Oracle address (check for list at www.github.com/DecentralizedDerivatives/Oracles)
  bytes32 public startDate;//Start Date of Swap - is the hex representation of the date variable in YYYYMMDD
  bytes32 public endDate;//End Date of Swap - is the hex representation of the date variable in YYYYMMDD
  address public creator;//The Factory it was created from
  bool public cancel_long;//The cancel variable.  If 0, no parties want to cancel.   Once Swap is started, both parties can cancel.  If cancel =1, other party is trying to cancel
  bool public cancel_short;
  bool public paid_short;
  bool public paid_long;
  uint public share_long;
  uint public share_short;
  address party;
  bool long;
  struct DocumentStruct{bytes32 name; uint value;}
  mapping(address => uint256) balances;

modifier onlyState(SwapState expectedState) {require(expectedState == currentState);_;}

Oracle d;

  //this base function is run by the Factory
  function Swap(address OAddress, address _cpty1, address _creator) public{
      d = Oracle(OAddress);
      oracleID = OAddress;
      creator = _creator;
      party = _cpty1;
      currentState = SwapState.created;
    
  }


  //this function is where you enter the details of your swap.  
  //The Eligble Contract Participant variable (ECP) verifies that the party self identifies as eligible to enter into a swap based upon their jurisdiction
  //Be sure to send your collateral (margin) while entering the details.
  function CreateSwap(bool ECP, uint _margin, uint _margin2, uint _notional, bool _long, bytes32 _startDate, bytes32 _endDate) public onlyState(SwapState.created) payable {
      require(ECP);
      require (msg.sender == party);
      require(msg.value == Sf.mul(_margin,1000000000000000000));
      require(_endDate > _startDate);
      notional = _notional;
      long = _long;
      if (long){long_party = msg.sender;
        lmargin = Sf.mul(_margin,1000000000000000000);
        smargin = Sf.mul(_margin2,1000000000000000000);}
      else {short_party = msg.sender;
        smargin = Sf.mul(_margin,1000000000000000000);
        lmargin = Sf.mul(_margin2,1000000000000000000);
      }
      currentState = SwapState.open;
      endDate = _endDate;
      startDate = _startDate;
  }

  //This function is for those entering the swap.  
  //Needing to enter the details of the swap a second time ensures that your counterparty cannot modify the terms right before you enter the swap. 
  //Note you do not need to enter your collateral as a variable, however it must be submitted with the contract
  function EnterSwap(bool ECP, uint _margin, uint _notional, bool _long, bytes32 _startDate, bytes32 _endDate ) public onlyState(SwapState.open) payable returns (bool) {
      require(ECP);
      require(_long != long && notional == _notional && _startDate == startDate && _endDate == endDate);
      if (long) {short_party = msg.sender;
      require(msg.value >= smargin);
      require(lmargin >= _margin);
      }
      else {long_party = msg.sender;
      require(msg.value >=lmargin);
      require (smargin >= _margin);
      }
      currentState = SwapState.started;
      return true;
  }
  

//This function calculates the payout of the swap.  Note that the value of the underlying cannot reach zero, but get within .001 * the precision of the Oracle
    function Calculate() public onlyState(SwapState.started){
    uint p1=Sf.div(Sf.mul(1000,RetrieveData(endDate)),RetrieveData(startDate));
    if (p1 == 1000){
            share_long = lmargin;
            share_short = smargin;
        }
        else if (p1<1000){
              if(Sf.mul(notional,Sf.mul(Sf.sub(1000,p1),1000000000000000))>lmargin){share_long = 0; share_short =this.balance;}
              else {share_long = Sf.mul(Sf.mul(Sf.sub(1000,p1),notional),Sf.div(1000000000000000000,1000));
              share_short = this.balance -  share_long;
              }
          }
          
        else if (p1 > 1000){
               if(Sf.mul(notional,Sf.mul(Sf.sub(p1,1000),1000000000000000))>smargin){share_short = 0; share_long =this.balance;}
               else {share_short = Sf.mul(Sf.mul(Sf.sub(p1,1000),notional),Sf.div(1000000000000000000,1000));
               share_long = this.balance - share_short;
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
        lmargin = 0;
        smargin = 0;
        notional = 0;
        long = false;
        startDate =  '';
        endDate =  '';
        short_party = 0;
        long_party = 0;
        currentState = SwapState.created;
        msg.sender.transfer(this.balance);
    }

  else{
    if (msg.sender == long_party && paid_long == false){cancel_long = true;}
    if (msg.sender == short_party && paid_short == false){cancel_short = true;}
    if (cancel_long && cancel_short){
        short_party.transfer(smargin);
        long_party.transfer(lmargin);
        currentState = SwapState.ended;
      }
    }
  }

//If you want to check if the Calculate function can be run, enter the hex of the date in the RetrieveData field and see if it returns a non-zero value
  function RetrieveData(bytes32 key) public constant returns(uint) {
    DocumentStruct memory doc;
    (doc.name,doc.value) = d.documentStructs(key);
    require(doc.value>0);
    return doc.value;
  } 

}
