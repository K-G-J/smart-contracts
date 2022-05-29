//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract Array {

    uint256[] array;

    function create(uint256 _val) external {
        array.push(_val);
    }

    function update(uint256 i, uint256 _val) external {
        array[i] = _val;
    }

    function destroy(uint256 i) external {
        delete array[i];
    }

    function read() external view returns(uint256[] memory) {
        return array;
    }
}