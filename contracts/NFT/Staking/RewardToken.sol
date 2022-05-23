// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RewardToken is ERC20, ERC20Burnable, Ownable {
  using SafeMath for uint256;

  // address(s) that are allowed to interact with the reward token (Staking Contract)
  mapping(address => bool) controllers;
  // tracking the balances for each transaction 
  mapping(address => uint256) private _balances;

  uint256 private _totalSupply; // ammount of tokens minted
  uint256 constant public MAXIMUMSUPPLY=2000000000*10**18; // 2 million tokens max

  constructor() ERC20("RewardsToken", "RETO") {}

  // mint tokens for staking contract to issue
  function mint(address to, uint256 amount) external {
    require(controllers[msg.sender], "Only controllers can mint");
    require((_totalSupply + amount) <= MAXIMUMSUPPLY, "Maximum supply has been reached");
    _totalSupply = _totalSupply.add(amount);
    _balances[to] = _balances[to].add(amount);
    _mint(to, amount);
  }

  // in case supply needs to be burned (controller or wallet that issued contract) may burn tokens 
  function burnFrom(address account, uint256 amount) public override {
    if(controllers[msg.sender]) {
      _burn(account, amount);
    } else {
      super.burnFrom(account, amount);
    }
  }

  // authorize another address to mint rewards token 
  function addController(address controller) external onlyOwner {
    controllers[controller] = true;
  }

  // remove address authorization 
  function removeController(address controller) external onlyOwner {
    delete controllers[controller];
  }

  // returns total supply
  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }
}