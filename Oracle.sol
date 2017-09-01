pragma solidity ^0.4.4;

contract Oracle{
    address private owner;
    event Print(string _name, uint _value);
    modifier onlyOwner{require(msg.sender == owner);_;}
    struct DocumentStruct{bytes32 name; uint value;}
    mapping(bytes32 => DocumentStruct) public documentStructs;
    
    function Oracle(){
        owner = msg.sender;
    }
    function StoreDocument(bytes32 key,bytes32 name, uint value) onlyOwner returns (bool success) {
        documentStructs[key].value = value;
        documentStructs[key].name = name;
        Print(bytes32ToString(name),value);
        return true;
    }
    

    function RetrieveData(bytes32 key) public constant returns(uint) {
        uint d = documentStructs[key].value;
        return d;
    }
      function RetrieveName(bytes32 key) public constant returns(string) {
        bytes32 d = documentStructs[key].name;
        return bytes32ToString(d);
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
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (j = 0; j < charCount; j++) {
        bytesStringTrimmed[j] = bytesString[j];
    }
    return string(bytesStringTrimmed);
}
}