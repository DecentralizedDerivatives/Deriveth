pragma solidity ^0.4.13;

import "../contracts/Swap.sol";


contract Factory {
    address[] public newContracts;
    address public creator;
    address public oracleID;
    uint public fee;
    modifier onlyOwner{require(msg.sender == creator); _;}
    event Print(address _name, address _value);

    function Factory (address _oracleID){
        creator = msg.sender;  
        oracleID = _oracleID;
    }
    /*ie .01 ether = 1000 */
    function setFee(uint _fee) onlyOwner{
      fee = _fee *10000000000000;
    }

    function createContract () payable returns (address){
        require(msg.value >= fee);
        address newContract = new Swap(oracleID,msg.sender,creator);
        newContracts.push(newContract);
        Print(msg.sender,newContract);
        return newContract;
    } 
    function withdrawFee() onlyOwner {
        creator.transfer(this.balance);
    }
}
