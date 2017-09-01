pragma solidity ^0.4.4;

import "../contracts/Oracle.sol";

contract Swap {
  enum SwapState {open,started,ready,ended}
  SwapState public currentState;
  address public long_party;
  address public short_party;
  uint public notional;
  uint public lmargin;
  uint public smargin;
  address public oracleID;
  bytes32 public startDate;
  bytes32 public endDate;
  address public creator;
  uint public cancel;
  address party;
  bool long;

  mapping(address => uint256) balances;

modifier onlyState(SwapState expectedState) {require(expectedState == currentState);_;}

Oracle d;

  function Swap(address OAddress, address _cpty1, address _creator){
      d = Oracle(OAddress);
      oracleID = OAddress;
      creator = _creator;
      party = _cpty1;
    
  }
  
  function CreateSwap(bool ECP, uint _margin, uint _margin2, uint _notional, bool _long, bytes32 _startDate, bytes32 _endDate) payable {
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
  function EnterSwap(bool ECP) onlyState(SwapState.open) payable returns (bool) {
      require(ECP);
      if (long) {short_party = msg.sender;
      require(msg.value >= smargin);
      }
      else {long_party = msg.sender;
      require(msg.value >=lmargin);
      }
      currentState = SwapState.started;
      paid[long_party] = false;
      paid[short_party] = false;
      return true;
  }
  

  mapping(uint => uint) shares;

    function Caculate() onlyState(SwapState.started) returns (bool){
    uint p1=div(mul(1000,RetrieveData(endDate)),RetrieveData(startDate));
        if (p1 == 1000){
            shares[1] = lmargin;
            shares[2] = smargin;
        }
          if (p1<1000){
              if(mul(sub(1000,p1),1000000000000000000)>lmargin){shares[1] = 0; shares[2] =this.balance;}
              else {shares[1] = mul(mul(sub(1000,p1),notional),div(1000000000000000000,1000));
              shares[2] = this.balance -  shares[1];
              }
          }
          
          else if (p1 > 1000){
               if(mul(sub(p1,1000),1000000000000000000)>smargin){shares[2] = 0; shares[1] =this.balance;}
               else {shares[2] = mul(mul(sub(p1,1000),notional),div(1000000000000000000,1000));
               shares[1] = this.balance - shares[2];
               }
          }
      currentState = SwapState.ready;
    return true;
  }
  


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

  function Exit(){
    require(currentState != SwapState.ended);
    if (currentState == SwapState.open){
    if (msg.sender == party) selfdestruct(party);
    }

  else if (currentState == SwapState.started){
    var c = msg.sender == long_party ? 1 : 0;
    var d = msg.sender == short_party ? 2 : 0;
    var e = cancel + c + d;
    cancel = c + d;
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

  function RetrieveData(bytes32 key) public constant returns(uint) {
    DocumentStruct memory doc;
    (doc.name,doc.value) = d.documentStructs(key);
    assert(utfStringLength(bytes32ToString(doc.name)) > 0);
    return doc.value;
  }
  
   function bytes32ToString(bytes32 x) constant returns (string) {
    bytes memory bytesString = new bytes(32);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
        byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[charCount] = char;
            charCount++;
        }
    }
      }


    function utfStringLength(string str) constant
    returns (uint length)
    {
        uint i=0;
        bytes memory string_rep = bytes(str);

        while (i<string_rep.length)
        {
            if (string_rep[i]>>7==0)
                i+=1;
            else if (string_rep[i]>>5==0x6)
                i+=2;
            else if (string_rep[i]>>4==0xE)
                i+=3;
            else if (string_rep[i]>>3==0x1E)
                i+=4;
            else
                //For safety
                i+=1;

            length++;
        }
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