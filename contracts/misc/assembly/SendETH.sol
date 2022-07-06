// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0;

contract SendEth {
    address[2] owners = [0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,0xdD870fA1b7C4700F2BD7f44238821C26f7392148];
    function withdrawETH (address _to, uint256 _amount) external payable {
        bool success;
        assembly {
            for { let i := 0 } lt(i, 2) { i := add(i, 1) } { // for loop (i < 2 )
                let owner := sload(i) // owner is the storage value of i (first 2 slots are owner addresses)
                if eq(_to, owner) { // if _to = owner
                    success := call(gas(), _to, _amount, 0, 0, 0, 0) // passes remaining gas, receipient, amount
                }
            }
        }
        require(success, "Failed to send ETH");
    }
}