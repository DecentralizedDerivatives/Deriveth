pragma solidity ^0.4.13;

import "../contracts/Swap.sol";

//The Factory contract creates the individual swap contracts
contract Factory {
    address[] public newContracts;
    address public creator;
    address public oracleID; //address of Oracle
    uint public fee; //Cost of contract in Wei

    modifier onlyOwner{require(msg.sender == creator); _;}
    event Print(address _name, address _value);

    function Factory (address _oracleID){
        creator = msg.sender;  
        oracleID = _oracleID;
        fee = 10000000000000000;
    }
    /*ie .01 ether = 1000 */
    function setFee(uint _fee) onlyOwner{
      fee = _fee *10000000000000;
    }

    //This is the function participants will call.  Pay the fee, get returned your new swap address
    function createContract () payable returns (address){
        require(msg.value >= fee);
        address newContract = new Swap(oracleID,msg.sender,creator);
        newContracts.push(newContract);
        Print(msg.sender,newContract); //This is an event and allows DDA/ participants to see when new contracts are pushed.
        return newContract;
    } 
    function withdrawFee() onlyOwner {
        creator.transfer(this.balance);
    }
}
