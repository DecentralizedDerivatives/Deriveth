pragma solidity ^0.4.16;

//The oracle contract.  Detailed methodology on the Oracle can be found at Github.com/DecentralizedDerivatives/Oracles
//The Oracle is a database with price of the underlying by date (key)
contract Oracle{
    address private owner;
    event Print(string _name, uint _value);
    modifier onlyOwner{require(msg.sender == owner);_;}
    struct DocumentStruct{bytes32 name; uint value;}
    mapping(bytes32 => DocumentStruct) public documentStructs;
    
    function Oracle() public{
        owner = msg.sender;
    }
    function StoreDocument(bytes32 key,bytes32 name, uint value) public onlyOwner{
        documentStructs[key].value = value;
        documentStructs[key].name = name;
        Print(bytes32ToString(name),value);
    }
        
    function bytes32ToString(bytes32 x) public returns (string) {
    bytes memory bytesString = new bytes(32);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
        byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[charCount] = char;
            charCount++;
        }
    }
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (j = 0; j < charCount; j++) {
        bytesStringTrimmed[j] = bytesString[j];
    }
    return string(bytesStringTrimmed);
}
}
