pragma solidity ^0.4.13;

import "../contracts/Oracle.sol";

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
  uint public cancel;//The cancel variable.  If 0, no parties want to cancel.   Once Swap is started, both parties can cancel.  If cancel =1, other party is trying to cancel
  address party;
  bool long;

  mapping(address => uint256) balances;

modifier onlyState(SwapState expectedState) {require(expectedState == currentState);_;}

Oracle d;

  //this base function is run by the Factory
  function Swap(address OAddress, address _cpty1, address _creator){
      d = Oracle(OAddress);
      oracleID = OAddress;
      creator = _creator;
      party = _cpty1;
      currentState = SwapState.created;
    
  }


  //this function is where you enter the details of your swap.  
  //The Eligble Contract Participant variable (ECP) verifies that the party self identifies as eligible to enter into a swap based upon their jurisdiction
  //Be sure to send your collateral (margin) while entering the details.
  function CreateSwap(bool ECP, uint _margin, uint _margin2, uint _notional, bool _long, bytes32 _startDate, bytes32 _endDate) onlyState(SwapState.created) payable {
      require(ECP);
      require (msg.sender == party);
      require(msg.value == mul(_margin,1000000000000000000));
      cancel = 0;
      notional = _notional;
      long = _long;
      if (long){long_party = msg.sender;
        lmargin = mul(_margin,1000000000000000000);
        smargin = mul(_margin2,1000000000000000000);}
      else {short_party = msg.sender;
        smargin = mul(_margin,1000000000000000000);
        lmargin = mul(_margin2,1000000000000000000);
      }
      currentState = SwapState.open;
      endDate = _endDate;
      startDate = _startDate;
  }
  mapping(address => bool) paid;
  //This function is for those entering the swap.  
  //Needing to enter the details of the swap a second time ensures that your counterparty cannot modify the terms right before you enter the swap. 
  //Note you do not need to enter your collateral as a variable, however it must be submitted with the contract
  function EnterSwap(bool ECP, uint _margin, uint _notional, bool _long, bytes32 _startDate, bytes32 _endDate ) onlyState(SwapState.open) payable returns (bool) {
      require(ECP);
      require(_long == long && notional == _notional && _startDate == startDate && _endDate == endDate);
      if (long) {short_party = msg.sender;
      require(msg.value >= smargin);
      require(lmargin >= _margin);
      }
      else {long_party = msg.sender;
      require(msg.value >=lmargin);
      require (smargin >= _margin);
      }
      currentState = SwapState.started;
      paid[long_party] = false;
      paid[short_party] = false;
      return true;
  }
  

  mapping(uint => uint) shares;
//This function calculates the payout of the swap.  Note that the value of the underlying cannot reach zero, but get within .001 * the precision of the Oracle
    function Calculate() onlyState(SwapState.started) returns (bool){
    uint p1=div(mul(1000,RetrieveData(endDate)),RetrieveData(startDate));
        if (p1 == 1000){
            shares[1] = lmargin;
            shares[2] = smargin;
        }
          if (p1<1000){
              if(mul(notional,mul(sub(1000,p1),1000000000000000))>lmargin){shares[1] = 0; shares[2] =this.balance;}
              else {shares[1] = mul(mul(sub(1000,p1),notional),div(1000000000000000000,1000));
              shares[2] = this.balance -  shares[1];
              }
          }
          
          else if (p1 > 1000){
               if(mul(notional,mul(sub(1000,p1),1000000000000000))>smargin){shares[2] = 0; shares[1] =this.balance;}
               else {shares[2] = mul(mul(sub(p1,1000),notional),div(1000000000000000000,1000));
               shares[1] = this.balance - shares[2];
               }
          }
      currentState = SwapState.ready;
    return true;
  }
  

//Once calcualted, this function allows each party to withdraw their share of the collateral.
  function PaySwap() onlyState(SwapState.ready) returns (bool){
  if (msg.sender == long_party && paid[long_party] == false){
        paid[long_party] = true;long_party.send(shares[1]);
    }
    else if (msg.sender == short_party && paid[short_party] == false){
        paid[short_party] = true;short_party.send(shares[2]);
    }
    if (paid[long_party] && paid[short_party]){currentState = SwapState.ended;}
    return true;
  }

//This function allows both parties to exit.  If only the creator has entered the swap, then the swap can be cancelled and the details modified
//Once two parties enter the swap, the contract is null after cancelled

  function Exit(){
    require(currentState != SwapState.ended);
    require(currentState != SwapState.created);
    if (currentState == SwapState.open){
    if (msg.sender == party) {
        lmargin = 0;
        smargin = 0;
        notional = 0;
        currentState = SwapState.created;
        msg.sender.send(this.balance);
        }
    }

  else{
    var c = msg.sender == long_party ? 1 : 0;
    var f = msg.sender == short_party ? 2 : 0;
    var e = cancel + c + f;
    cancel = c + f;
    if (e > 2){
      if (msg.sender == short_party){ 
        long_party.send(lmargin);
        short_party.send(smargin);
      }
      else if (msg.sender == long_party){ 
        short_party.send(smargin);
        long_party.send(lmargin);
      }

    }
  }

}


  struct DocumentStruct{bytes32 name; uint value;}

//If you want to check if the Calculate function can be run, enter the hex of the date in the RetrieveData field and see if it returns a non-zero value
  function RetrieveData(bytes32 key) public constant returns(uint) {
    DocumentStruct memory doc;
    (doc.name,doc.value) = d.documentStructs(key);
    require(doc.value>0);
    return doc.value;
  }
  
  
    
  function mul(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
