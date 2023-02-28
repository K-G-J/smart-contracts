// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7;

// raw_call receiver written in Solidity because supports dynamic array
contract RawCallReceiver {
    event Log(uint256 x, uint256 y);

    function test(
        uint256 x,
        uint256 y,
        uint256[] calldata xs
    ) external returns (uint256[] memory) {
        require(x == y, "x != y");
        emit Log(x, y);
        emit Log(xs[0], xs[1]);

        uint256[] memory ys = new uint[](2);
        ys[0] = 888;
        ys[1] = 999;

        return ys;
    }
}
