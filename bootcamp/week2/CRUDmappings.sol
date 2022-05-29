// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract mappings {

    mapping(uint256 => string) myMapping;
    uint256[] keys;

    function create(uint256 _val, string calldata _string) external {
        myMapping[_val] = _string;
        keys.push(_val);
    }

    function update(uint256 _val, string calldata _string) external {
        myMapping[_val] = _string;
    }

    function destroy(uint256 _val) external {
        delete myMapping[_val];
        keys[_val] = keys[keys.length - 1];
    }

    function readOne(uint256 _val) external view returns (string memory mappingValue) {
        return myMapping[_val];
    }

    function readAll() external view returns (string[] memory mappingValues) {
        uint256 length = keys.length;
        mappingValues = new string[](length);
        for (uint i = 0; i < length; i++) {
            mappingValues[i] = myMapping[keys[i]];
        }
    }
}