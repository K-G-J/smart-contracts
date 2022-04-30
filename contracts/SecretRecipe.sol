//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SecretRecipe is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private recipeIds;
    Counters.Counter private permittedAddresses;

    struct Recipe {
        uint256 id;
        string title;
        string description;
        string[] ingredients;
        string[] steps;
        string[] images;
    }

    mapping(uint256 => Recipe) public idToRecipe;
    mapping(address => bool) public permitted;

    modifier onlyPermitted() {
        require(permitted[msg.sender], "Permission not granted");
        _;
    }

    address[] whitelist;

    event RecipeEvent(uint256 id);

    constructor() {
        permittedAddresses.increment();
        permitted[msg.sender] = true;
        whitelist.push(msg.sender);
    }

    function addRecipe(
        string calldata _title,
        string calldata _description,
        string[] memory _ingredients,
        string[] memory _steps,
        string[] memory _images)
        external onlyPermitted {
        recipeIds.increment();
        uint256 recipeId = recipeIds.current();
        Recipe storage recipe = idToRecipe[recipeId];
        recipe.title = _title;
        recipe.description = _description;
        recipe.ingredients = _ingredients;
        recipe.steps = _steps;
        recipe.images = _images;
        emit RecipeEvent(recipeId);
    }

    function editRecipe(
    uint256 _id,
    string calldata _title,
    string calldata _description,
    string[] memory _ingredients,
    string[] memory _steps,
    string[] memory _images)
    external onlyPermitted {
        idToRecipe[_id].title = _title;
        idToRecipe[_id].description = _description;
        idToRecipe[_id].ingredients = _ingredients;
        idToRecipe[_id].steps = _steps;
        idToRecipe[_id].images = _images;
        emit RecipeEvent(_id);
    }

    function deleteRecipe(uint256 _id) external onlyPermitted {
        recipeIds.decrement();
        delete idToRecipe[_id];
        emit RecipeEvent(_id);
    }

    function getRecipes() external view onlyPermitted returns(Recipe[] memory) {
        uint256 recipeCount = recipeIds.current();
        Recipe[] memory recipes = new Recipe[](recipeCount);
        for (uint256 i = 0; i < recipeCount; i ++) {
            Recipe storage recipe = idToRecipe[i + 1];
            recipes[i] = recipe;
        }
        return recipes;
    }

    function addPermitted(address _address) external onlyPermitted {
        permittedAddresses.increment();
        permitted[_address] = true;
        whitelist.push(_address);
    }

    function removePermitted(address _address) external onlyPermitted {
        uint256 permittedCount = permittedAddresses.current();
        delete permitted[_address];
        for (uint256 i = 0; i < permittedCount; i ++) {
            if (whitelist[i] == _address) {
                whitelist[i] = whitelist[whitelist.length - 1];
                whitelist.pop();
                permittedAddresses.decrement();
            }
        }
    }

    function getPermitted() external view returns (address[] memory) {
        return whitelist;
    }
}