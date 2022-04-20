// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";

import "hardhat/console.sol";

contract Hab3 {
    using Counters for Counters.Counter;
    Counters.Counter private goalIds;

    struct Goal {
        uint256 id;
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
    mapping (address => Goal[]) private userGoals;

    event GoalAdded(uint256 indexed id, address user, string goal, uint time);
    event StepAdded(uint256 indexed goalId, address user, string step, uint time);
    event StepCompleted(uint256 indexed goalId, address user, string step, uint time);
    event GoalCompleted(uint256 indexed id, address user, string goal, uint time);

    constructor() {
        /* mint tokens */
        /* create some different types of ERC155 tokens to reward users for completetion */
    }

    function setGoal (string calldata _goal, string[] calldata _steps) public payable {
        goalIds.increment();
        uint256 newGoalId = goalIds.current();
        uint256 stepAmount = _steps.length;
        for (uint i = 0; i < stepAmount; i ++) {
            idToGoal[newGoalId].steps.push(Step(i+1, _steps[i], false));
        }
        idToGoal[newGoalId].id = newGoalId;
        idToGoal[newGoalId].goal = _goal;
        idToGoal[newGoalId].createdAt = block.timestamp;
        userGoals[msg.sender].push(idToGoal[newGoalId]);
        emit GoalAdded(newGoalId, msg.sender, _goal, block.timestamp);
    }

    function addStep (uint _goalId, string calldata _step) public payable {
        uint stepCount = idToGoal[_goalId].steps.length;
        idToGoal[_goalId].steps.push(Step(stepCount+1, _step, false));
        for(uint i = 0; i < userGoals[msg.sender].length; i++) {
            if(userGoals[msg.sender][i].id == _goalId) {
                userGoals[msg.sender][i].steps.push(Step(stepCount+1, _step, false));
            }
        }
        emit StepAdded(_goalId, msg.sender, _step, block.timestamp);
    }

    function completeStep(uint _goalId, uint _stepId) public payable returns(Step[] memory) {
        for (uint i = 0; i < idToGoal[_goalId].steps.length; i++) {
            if(idToGoal[_goalId].steps[i].id == _stepId) {
                idToGoal[_goalId].steps[i].completed = true;
                /* some type of token reward */
                emit StepCompleted(_goalId, msg.sender, idToGoal[_goalId].steps[i].step, block.timestamp);
            }
        }
        for (uint i = 0; i < userGoals[msg.sender].length; i++) {
            if(userGoals[msg.sender][i].id == _goalId) {
                Step[] storage goalSteps = userGoals[msg.sender][i].steps;
                for(uint x = 0; x < goalSteps.length; x++) {
                    if(goalSteps[x].id == _stepId) {
                        goalSteps[x].completed == true;
                    }
                }
            }
        }
        return idToGoal[_goalId].steps;
    }

    function completeGoal(uint _goalId) public payable {
        idToGoal[_goalId].completed = true;
        /* some type of token reward */
        Goal[] storage goalArr = userGoals[msg.sender]; 
        for(uint i = 0; i < goalArr.length; i ++) {
            if(goalArr[i].id == _goalId) {
                goalArr[i].completed = true;
            }
        }
        emit GoalCompleted(_goalId, msg.sender, idToGoal[_goalId].goal, block.timestamp);
    }

    function getUserGoals() public view returns (Goal[] memory) {
        return userGoals[msg.sender];
    }

    function getCurrentGoals() public view returns (Goal[] memory)  {
        uint count = 0;
        uint currentIndex = 0;
        for(uint i = 0; i < userGoals[msg.sender].length; i++) {
            if(!(userGoals[msg.sender][i].completed)) {
                count += 1;
            }
        }
        Goal[] memory currentGoals = new Goal[](count);
        for(uint i = 0; i < userGoals[msg.sender].length; i++) {
            if(!(userGoals[msg.sender][i].completed)) {
                currentGoals[currentIndex] = userGoals[msg.sender][i];
                currentIndex += 1;
            }
        }
        return currentGoals;
    }

    function getCompletedGoals() public view returns (Goal[] memory)  {
        uint count = 0;
        uint currentIndex = 0;
        for(uint i = 0; i < userGoals[msg.sender].length; i++) {
            if(userGoals[msg.sender][i].completed) {
                count += 1;
            }
        }
        Goal[] memory completedGoals = new Goal[](count);
        for(uint i = 0; i < userGoals[msg.sender].length; i++) {
            if(userGoals[msg.sender][i].completed) {
                completedGoals[currentIndex] = userGoals[msg.sender][i];
                currentIndex += 1;
            }
        }
        return completedGoals;
    }
}