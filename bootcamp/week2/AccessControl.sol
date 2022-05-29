//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

error NotOwner();

contract AccessControl {

    address immutable owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier OnlyOwner() {
        if(msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    function foo(string calldata _firstWord, string calldata _secondWord) external view OnlyOwner returns (string memory words) {
        words = string(abi.encodePacked(_firstWord, " ", _secondWord));
    }
}