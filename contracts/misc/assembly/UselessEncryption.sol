// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0;

contract UselessEncryption {
    function encrypt(string memory _input, bool _decrypt) external pure returns (string memory) {
        bytes32 output;
        assembly {
            function stringToBytes(a) -> b { // converts text string to byte array (returns b)
                b := mload(add(a, 32)) // 32 byte slots
            }
            function addToBytes(bs, decrypt) -> r { // returns r
                if eq(decrypt, false) {
                    // if decrypt is false add 01 to each byte of string
                    mstore(0x0, add(bs, 0x0101010101010101010101010101010101010101010101010101010101010101))
                }
                if eq(decrypt, true) {
                    // if decrypt is true subtract 01 to get back original text 
                    mstore(0x0, sub(bs, 0x0101010101010101010101010101010101010101010101010101010101010101))
                }
                r := mload(0x0)
            }
            let byteString := stringToBytes(_input)
            output := addToBytes(byteString, _decrypt)
        }
        // convert byte output back into string
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) bytesArray[i] = output[i];
        return string(bytesArray);
    }
}