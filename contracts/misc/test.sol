// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

error FundingContractFailed();

contract test {
    
    function concat(string memory one, string memory two) external pure returns (string memory concatedString) {
        concatedString = string.concat(one, " ", two);
    }

}
