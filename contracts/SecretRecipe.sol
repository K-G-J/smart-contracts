//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SecretReciple is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private recipeIds;

    struct Recipe {
        uint256 id;
        string title;
        string description;
        string[] ingredients;
        string[] steps;
        string[] images;
    }

    mapping(uint256 => Recipe) private idToRecipe;
    mapping(address => bool) permitted;

    modifier onlyPermitted() {
        require(permitted[msg.sender], "Permission not granted");
        _;
    }

    event RecipeEvent(uint256 id);

    constructor() {
        permitted[msg.sender] = true;
    }

    function addRecipe(string calldata _title, string calldata _description, string[] memory _ingredients,  string[] memory _steps, string[] memory _images) onlyPermitted external {
        _recipeIds.increment();
        uint256 recipeId = recipeIds.current();
        Recipe storage recipe = idToRecipe[recipeId];
        recipe.title = _title;
        recipe.description = _description;
        recipe.ingredients = _ingredients;
        recipe.steps = _steps;
        recipe.images = _images;
        emit RecipeEvent(recipeId);
    }

    function editRecipe(uint256 _id, string calldata _title, string calldata _description, string[] memory _ingredients,  string[] memory _steps, string[] memory _images) onlyPermitted external {
        require(idToRecipe[_id].id > 0, "Recipe does not exist");
        idToRecipe[_id].title = _title;
        idToRecipe[_id].description = _description;
        idToRecipe[_id].ingredients = _ingredients;
        idToRecipe[_id].steps = _steps;
        idToRecipe[_id].images = _images;
        emit RecipeEvent(_id);
    }

    function deleteRecipe(uint256 _id, string calldata _title, string calldata _description, string[] memory _ingredients,  string[] memory _steps, string[] memory _images) onlyPermitted external {
        require(idToRecipe[_id].id > 0, "Recipe does not exist");
        delete idToGoal[_id];
    }

    function getRecipes() view external onlyPermitted returns(Recipe[] memory) {
        uint256 recipeCount = recipeIds.current();
        Recipe[] recipes = new Recipe[](recipeCount) {
            for (uint256 i = 0; i < recipeCount; i ++) {
                uint256 currentId = i + 1;
                Recipe storage recipe = idToRecipe[currentId];
                recipes[i] = recipe;
            }
        }
        return recipes;
    }

    function getPermitted view external returns(address[] memory) {
        uint256 permittedCount = 0;

        for (i = 0; i < )
    }
}