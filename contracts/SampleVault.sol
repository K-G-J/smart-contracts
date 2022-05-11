// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";

// EACAggregatorProxy is used for chainlink oracle
interface EACAggregatorProxy {
  function latestAnswer() external view returns (int256);
}

// Uniswap v3 interface
interface IUniswapRouter is ISwapRouter {
  function refundETH() external payable;
}

// Add deposit function for WETH
interface DepositableERC20 is IERC20 {
  function deposit() external payable; // deposit ETH to WETH to interact as ERC20
}

contract SampleVault {
  uint public version = 1;
  /* Kovan Addresses */
  address public daiAddress = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
  address public wethAddress = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;
  address public uinswapV3QuoterAddress = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;
  address public uinswapV3RouterAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
  address public chainLinkETHUSDAddress = 0x9326BFA02ADD2366b30bacB125260Af641031331; // oracle to get latest price

  uint public ethPrice = 0;
  uint public usdTargetPercentage = 40; // 60% in Ethereum and 40% in Dai
  uint public usdDividendPercentage = 25; // 25% of 40% = 10% Annual Drawdown
  uint private dividendFrequency = 3 minutes; // change to years for production to setup prepetual fund 
  uint public nextDividendTS;
  address public owner;

  using SafeERC20 for IERC20;
  using SafeERC20 for DepositableERC20;

  IERC20 daiToken = IERC20(daiAddress);
  DepositableERC20 wethToken = DepositableERC20(wethAddress);
  IQuoter quoter = IQuoter(uinswapV3QuoterAddress);
  IUniswapRouter uniswapRouter = IUniswapRouter (uinswapV3RouterAddress);

  event myVaultLog(string msg, uint ref);

  constructor() {
    console.log('Deploying myVault Version:', version);
    nextDividendTS = block.timestamp + dividendFrequency;
    owner = msg.sender;
  }

  function getDaiBalance() public view returns(uint) {
    return daiToken.balanceOf(address(this)); // balance of Dai token
  }

  function getWethBalance() public view returns(uint) {
    return wethToken.balanceOf(address(this)); // balance of wrapped ETH
  }

  // returns total balance of vault
  function getTotalBalance() public view returns(uint) {
    require(ethPrice > 0, "ETH price has not been set");
    uint daiBalance = getDaiBalance();
    uint wethBalance = getWethBalance();
    uint wethUSD = wethBalance * ethPrice; // US dollar value of WETH (assumes both assets have 18 decimals)
    uint totalBalance = wethUSD + daiBalance;
    return totalBalance;
  }

  // get quote for transaction from Uniswap
  function updateEthPriceUniswap() public returns(uint) {
    uint ethPriceRaw = quoter.quoteExactOutputSingle(daiAddress,wethAddress,3000,100000,0);
    ethPrice = ethPriceRaw / 100000;
    return ethPrice;
  }

  // get different quote from ChainLink
  function updateEthPriceChainlink() public returns(uint) {
    int256 chainLinkEthPrice = EACAggregatorProxy(chainLinkETHUSDAddress).latestAnswer();
    ethPrice = uint(chainLinkEthPrice / 100000000);
    return ethPrice;
  }

  function buyWeth(uint amountUSD) internal {
    uint256 deadline = block.timestamp + 15;
    uint24 fee = 3000;
    address recipient = address(this);
    uint256 amountIn = amountUSD; // includes 18 decimals
    uint256 amountOutMinimum = 0; // change to avoid front running on mainnet 
    uint160 sqrtPriceLimitX96 = 0;
    emit myVaultLog('amountIn', amountIn);
    require(daiToken.approve(address(uinswapV3RouterAddress), amountIn), "DAI approve failed"); // approve Uniswap to spend for ERC20 token 
    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
      daiAddress,
      wethAddress,
      fee,
      recipient,
      deadline,
      amountIn,
      amountOutMinimum,
      sqrtPriceLimitX96
    );
    uniswapRouter.exactInputSingle(params);
    uniswapRouter.refundETH(); // return any ETH to account 
  }

  function sellWeth(uint amountUSD) internal {
    uint256 deadline = block.timestamp + 15;
    uint24 fee = 3000;
    address recipient = address(this);
    uint256 amountOut = amountUSD; // includes 18 decimals
    uint256 amountInMaximum = 10 ** 28 ;
    uint160 sqrtPriceLimitX96 = 0;
    require(wethToken.approve(address(uinswapV3RouterAddress), amountOut), 'WETH approve failed');
    ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams(
      wethAddress,
      daiAddress,
      fee,
      recipient,
      deadline,
      amountOut,
      amountInMaximum,
      sqrtPriceLimitX96
    ); // declare amount out in US dollar
    uniswapRouter.exactOutputSingle(params);
    uniswapRouter.refundETH();
  }

  // takes portfolio percentage to rebalance back to 60-40 strategy 
  function rebalance() public {
    require(msg.sender == owner, "Only the owner can rebalance their account");
    uint usdBalance = getDaiBalance();
    uint totalBalance = getTotalBalance(); 
    uint usdBalancePercentage = 100 * usdBalance / totalBalance; // working with integers so * 100 first
    emit myVaultLog("usdBalancePercentage", usdBalancePercentage);
    if (usdBalancePercentage < usdTargetPercentage) {
      uint amountToSell = totalBalance / 100 * (usdTargetPercentage - usdBalancePercentage);
      emit myVaultLog("amountToSell", amountToSell);
      require (amountToSell > 0, "Nothing to sell");
      sellWeth(amountToSell); // case: sell WETH to balance 
    } else {
      uint amountToBuy = totalBalance / 100 * (usdBalancePercentage - usdTargetPercentage);
      emit myVaultLog("amountToBuy", amountToBuy);
      require (amountToBuy > 0, "Nothing to buy");
      buyWeth(amountToBuy); // case: buy WETH to balance
    }
  }

  function annualDividend() public {
    require(msg.sender == owner, "Only the owner can drawdown their account");
    require(block.timestamp > nextDividendTS, "Dividend is not yet due");
    uint balance = getDaiBalance();
    uint amount = (balance * usdDividendPercentage) / 100;
    nextDividendTS = block.timestamp + dividendFrequency; // set timestamps before external call
    daiToken.safeTransfer(owner, amount); // use safeTransfer to transfer owner due amount this dividend
  }

  // remove entire Dai and WETH balance from account (if not using dividend)
  function closeAccount() public {
    require(msg.sender == owner, "Only the owner can close their account");
    uint daiBalance = getDaiBalance();
    if (daiBalance > 0) {
      daiToken.safeTransfer(owner, daiBalance);
    }
    uint wethBalance = getWethBalance();
    if (wethBalance > 0) {
      wethToken.safeTransfer(owner, wethBalance);
    }
  }

  // default function that allows contract to recieve ETH
  receive() external payable {
    // accept ETH, do nothing as it would break the gas fee for a transaction
  }

  // Wrap ETH after ETH is recieved by the contract
  function wrapETH() public {
    require(msg.sender == owner, "Only the owner can convert ETH to WETH");
    uint ethBalance = address(this).balance;
    require(ethBalance > 0, "No ETH available to wrap");
    emit myVaultLog('wrapETH', ethBalance);
    wethToken.deposit{ value: ethBalance }(); // Wrap ETH to use in portfolio using DepositableERC20 interface
  }
  
}