// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AutomaticDeprecation {
    
    modifier isActive() {
        require(block.number <= SOME_BLOCK_NUMBER);
        _;
    }

    function deposit() public isActive {
        // some code
    }

    function withdraw() public {
        // some code 
    }
}