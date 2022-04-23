// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.4;

/* NFT collection contract(should be Ownable) */
import "./NFTCollection.sol";
/* ERC20 smart contract token that issues rewards (should be Ownable) */
import "./RewardToken.sol"; 

contract NFTStaking is Ownable, IERC721Receiver {
  
  uint256 public totalStaked;

  // struct to store a stake's token, owner, and earning values
  struct Stake {
    uint tokenId;
    uint48 timestamp;
    address owner;
  }

  event NFTStaked(address owner, uint tokenId, uint256 value);
  event NFTUnstaked(address owner, uint256 tokenId, uint256 value);
  event Claimed(address owner, uint256 amount);

  // Points to NFT Collection Smart Contract
  NFTCollection nft;
  // Points to staking Rewards Token Contract
  RewardToken token; 

  // Referenced tokenId to staked
  mapping(uint256 => Stake) public vault;

  constructor(Collection _nft, N2DRewards _token) {
    nft = _nft;
    token = _token;
  }

  function stake(uint256[] calldata tokenIds) external {
    uint256 tokenId;
    totalStaked += tokenIds.length;
    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      require(nft.ownerOf(tokenId) == msg.sender, "not your token");
      require(vault[tokenId].tokenId == 0, "already staked");

      nft.transferFrom(msg.sender, address(this), tokenId);
      emit NFTStaked(msg.sender, tokenId, block.timestamp);

      vault[tokenId] = Stake({
        owner: msg.sender,
        tokenId: uint24(tokenId),
        timestamp: uint48(block.timestamp)
      });
    }
  }

  function _unstakeMany(address account, uint256[] calldata tokenIds) internal {
    uint256 tokenId;
    totalStaked -= tokenIds.length;
    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      Stake memory staked = vault[tokenId];
      require(staked.owner == msg.sender, "not an owner");
      
      delete vault[tokenId];
      emit NFTUnstaked(account, tokenId, block.timestamp);
      nft.transferFrom(address(this), account, tokenId);
    }
  }

  // sender claims rewards for their staked tokens 
  function claim(uint256[] calldata tokenIds) external {
      _claim(msg.sender, tokenIds, false);
  }

  // contract claims rewards to send to specific address 
  function claimForAddress(address account, uint256[] calldata tokenIds) external {
      _claim(account, tokenIds, false);
  }

  // sender claims rewards and unstakes their tokens
  function unstake(uint256[] calldata tokenIds) external {
      _claim(msg.sender, tokenIds, true);
  }

    function _claim(address account, uint256[] calldata tokenIds, bool _unstake) internal {
    uint256 tokenId;
    uint256 earned = 0;

    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      Stake memory staked = vault[tokenId];
      require(staked.owner == account, "not an owner");

      uint256 stakedAt = staked.timestamp;
      // amount issued to token staker every time a block is processed (gwei)
      earned += 10000 ether * (block.timestamp - stakedAt) / 1 days;
      vault[tokenId] = Stake({
        owner: acount, 
        token: uint24(tokenId),
        // reset timestamp
        timestamp: uint48(block.timestamp)
      });
    }

  /* Retrieve Staking Information Functions */

  // returns how much user has earned in rewards per day and second (formatted 2 decimals)
  function earningInfo(uint256 tokenIds) external view returns (uint256[2] memory info) {
     uint256 tokenId;
     uint256 totalScore = 0;
     uint256 earned = 0;
      Stake memory staked = vault[tokenId];
      uint256 stakedAt = staked.timestamp;
      earned += 100000 ether * (block.timestamp - stakedAt) / 1 days;
    uint256 earnRatePerSecond = totalScore * 1 ether / 1 days;
    earnRatePerSecond = earnRatePerSecond / 100000;
    // earned, earnRatePerSecond
    return [earned, earnRatePerSecond];
  }
     
    uint256 earnRatePerSecond = totalScore * 1 ether / 1 days;
    earnRatePerSecond = earnRatePerSecond / 100000;
    // earned, earnRatePerSecond
    return [earned, earnRatePerSecond];
  }

  // returns ammount of nfts staked on the vault (should never be used inside of transaction because of gas fee)
  function balanceOf(address account) public view returns (uint256) {
    uint256 balance = 0;
    uint256 supply = nft.totalSupply();
    for (uint i = 1; i <= supply; i++) {
      if(vault[i].owner == account) {
        balance += 1;
      }
    }
    return balance;
  }

    // returns tokenIds of owner  (should never be used inside of transaction because of gas fee)
  function tokensOfOwner(address account) public view returns (uint256[] memory ownerTokens) {

    uint256 supply = nft.totalSupply();
    uint256[] memory tmp = new uint256[](supply);

    uint256 index = 0;
    for(uint tokenId = 1; tokenId <= supply; tokenId++) {
      if (vault[tokenId].owner == account) {
        tmp[index] = vault[tokenId].tokenId;
        index +=1;
      }
    }

    uint256[] memory tokens = new uint256[](index);
    for(uint i = 0; i < index; i++) {
      tokens[i] = tmp[i];
    }

    return tokens;
  }

  function onERC721Received(
    address,
    address from,
    uint256,
    bytes calldata
  ) external pure override returns (bytes4) {
    require(from == address(0x0), "Cannot send nfts to Vault directly");
    return IERC721Receiver.onERC721Received.selector;
  }
}