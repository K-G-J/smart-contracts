// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";

import "hardhat/console.sol";

contract Hab3 {
    using Counters for Counters.Counter;
    Counters.Counter private goalIds;

    struct Goal {
        string goal;
        bool completed;
        uint createdAt;
        Step[] steps;
    }

    struct Step {
        uint256 id;
        string step;
        bool completed;
    }

    mapping(uint256 => Goal) private idToGoal;
    mapping (address => Goal) private userGoals;

    constructor() {
        // mint tokens 
    }

    function setGoal (string calldata _goal, string[] calldata _steps) public payable {
        goalIds.increment();
        uint256 newGoalId = goalIds.current();
        uint256 stepAmount = _steps.length;
        Step[] storage _goalSteps = new Step[](stepAmount);
        for (uint i = 0; i < stepAmount; i ++) {
            _goalSteps[i] = Step({
                id: i + 1,
                step: _steps[i],
                completed: false
            });
        }
        idToGoal[newGoalId] = Goal(_goal, false, block.timestamp, _goalSteps);
        Goal memory newGoal = idToGoal[newGoalId];
        userGoals[msg.sender] = newGoal;
    }
}