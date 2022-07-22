//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

error NotOwner();
error NotCorrectAmmount();
error TransferFailed();

contract Wallet {

    address immutable owner;

    uint256 balance;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    constructor(address _owner) {
        owner = _owner;
    }

    function deposit(uint256 _amount) public payable onlyOwner {
        if (msg.value != _amount) {
            revert NotCorrectAmmount();
        }
        balance += _amount;
    }

    function withdraw() external payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        if (!success) {
            revert TransferFailed();
        }
    }

    receive() external payable {
        balance += msg.value;
    }
}