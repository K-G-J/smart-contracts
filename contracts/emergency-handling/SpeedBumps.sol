// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SpeedBumps {

    struct RequestedWithdrawl {
        uint amount;
        uint time;
    }

    mapping (address => uint) private balances;
    mapping (address => RequestedWithdrawl) private requestedWithdrawals;
    uint constant withdrawalWaitPeriod = 28 days; // 4 weeks

    function requestWithdrawl() public {
        if (balances[msg.sender] > 0) {
            uint amountToWithdraw = balances[msg.sender];
            balances[msg.sender] = 0; // for simplicity, withdraw everything;
            // presumably, the deposit function prevents new deposits when withdrawls are in progress

            requestedWithdrawals[msg.sender] = RequestedWithdrawl({
                amount: amountToWithdraw,
                time: block.timestamp
            });
        }
    }

    function withdraw() public {
        if (requestedWithdrawals[msg.sender].amount > 0 && block.timestamp > requestedWithdrawals[msg.sender].time + withdrawalWaitPeriod) {
            uint amountToWithdraw = requestedWithdrawals[msg.sender].amount;
            requestedWithdrawals[msg.sender].amount = 0;

            (bool success, ) = msg.sender.call{value: amountToWithdraw}("");
            require(success, "Transfer failed.");
        }
    }
}