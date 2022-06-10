// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

error TimeExpired();

/*
1. Create a permissionless contract that allows one to exchange DAI for an ERC20 token called STAR.
2. The contract should mint STAR directly or allow an approved address to fund the contract with STAR
3. The cost of STAR should increase as the supply of STAR decreases (or increases in the case of minting). 
Implementing any kind of bonding curve (linear, polynomial, exponential, etc.) would be acceptable.
4. The contract should only be open for swaps for 5 days. After the time has expired, any call should fail.
5. All DAI proceeds should be deposited instantly into a Yearn vault.
*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./contracts/DeFi/SimpleVault.sol"

contract mintStar {

    IERC20 public immutable daiToken;
    IERC20 public immutable starToken;

    SimpleVault public immutable vault;

    uint256 public starSupply;
    uint256 public constant DURATION = 5 days;
    uint256 public immutable startTime;

    modifier isOpen() {
       require(block.timestamp <= startTime + DURATION, "Time Expired")
       _;
    }

    constructor(IERC20 _daiToken, IERC20 _starToken, SimpleVault _vault) {
        daiToken = _daiToken;
        starToken = _starToken;
        vault = _vault;
        startTime = block.timestamp;
    }

    function _mintStar(uint256 _amount) internal {
        starSupply += _amount;
        starToken.safeMint(msg.sender, _amount);
    }

    function exchange(uint256 _amount) external isOpen {
        daiToken.transferFrom(msg.sender, address(this), _amount);
        uint256 amountToMint = _getStarAmount(_amount);
        daiToken.approve(address(vault), _amount);
        vault.deposit(_amount);
        _mintStar(amountToMint);
    }

    function _getStarAmount(uint256 _amount) internal returns (uint256 amountToMint) {
        uint256 newStarTotal = starSupply + _amount;
        amountToMint = (newStarTotal / starSupply);
    }
    
}