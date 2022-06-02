// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

error FundingContractFailed();

contract test {
    constructor (uint256 _amount) {
        (bool success, ) = payable(address(this)).call{value: _amount}("");
        if (!success) {
            revert FundingContractFailed();
            }
    } 

}
