// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
  uint256 public totalWaves;
  address[] public wavers;

  constructor() {
    console.log("Yo yo, I am a contract and I am smart");
  }

  function wave() public {
    totalWaves += 1;
    console.log("%s has waved!", msg.sender);
    wavers.push(msg.sender);
  }

  function getTotalWaves() public view returns (uint256) {
    console.log("We have %d total waves!", totalWaves);
    return totalWaves;
  }

  function getWavers() public view returns(address[] memory) {
      return wavers;
  }
}