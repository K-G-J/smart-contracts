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
    mapping (address => Goal[]) private userGoals;

    event GoalAdded(address user, string goal, uint time);
    event StepAdded(address user, string step, uint time);
    event StepCompleted(address user, string step, uint time);
    event GoalCompleted(address user, string goal, uint time);

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
        idToGoal[newGoalId].goal = _goal;
        idToGoal[newGoalId].createdAt = block.timestamp;
        userGoals[msg.sender].push(idToGoal[newGoalId]);
        emit GoalAdded(msg.sender, _goal, block.timestamp);
    }

    function addStep (uint _goalId, string calldata _step) public payable {
        uint stepCount = idToGoal[_goalId].steps.length;
        idToGoal[_goalId].steps.push(Step(stepCount+1, _step, false));
        emit StepAdded(msg.sender, _step, block.timestamp);
    }

    function completeStep(uint _goalId, uint _stepId) public payable returns(Step[] memory) {
        Step[] memory stepArr = idToGoal[_goalId].steps;
        for (uint i = 0; i < stepArr.length; i++) {
            if(stepArr[i].id == _stepId) {
                stepArr[i].completed = true;
                // some type of token reward 
                emit StepCompleted(msg.sender, stepArr[i].step, block.timestamp);
            }
        }
        return stepArr;
    }

    function completeGoal(uint _goalId) public payable {
        idToGoal[_goalId].completed = true;
        emit GoalCompleted(msg.sender, idToGoal[_goalId].goal, block.timestamp);
        // some type of token reward 
    }

    function getUserGoals() public view returns (Goal[] memory) {

    }

    function getCurrentGoals() public view returns (Goal[] memory)  {

    }

    function getCompletedGoals() public view returns (Goal[] memory)  {

    }
}