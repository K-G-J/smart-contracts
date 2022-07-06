// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0;

contract StoringData {
    function setData(uint256 newValue) public {
        assembly {
            sstore(0, newValue) // store value in first memory slot in storage 
        }
    }

    function getData() public view returns(uint256) {
        assembly {
            let v := sload(0) // load data from slot 0 in storage
            mstore(0x80, v) // store data in memory 80 position before return
            return(0x80, 32) // return as 32-byte uint 
        }
    }
}