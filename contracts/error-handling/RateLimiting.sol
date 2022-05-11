// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RateLimiting {
    uint internal period; // how many blocks before limit resets
    uint internal limit; // max ether to withdraw per period
    uint internal currentPeriodEnd; // block which the current period ends at
    uint internal currentPeriodAmount; // amount already withdrawn this period

    constructor(uint _period, uint _limit) {
        period = _period;
        limit = _limit;

        currentPeriodEnd = block.number + period; // block.number not reccomended for time checks (illustrative purposes only)
    }   

    function withdraw(uint amount) public {
        // Update period before proceeding
        updatePeriod();

        // Prevent overflow
        uint totalAmount = currentPeriodAmount + amount;
        require(totalAmount <= currentPeriodAmount, "overflow");

        // Disallow withdrawls that exceed current rate limit
        require(totalAmount < limit, "exceeds period limit");
        currentPeriodAmount += amount;

        (bool success, ) = msg.sender.call{ value: amount }("");
        require(success, "Failed to send Ether");
    } 

    function updatePeriod() internal {
        if (currentPeriodEnd < block.number) {
            currentPeriodEnd = block.number + period;
            currentPeriodAmount = 0;
        }
    }
}