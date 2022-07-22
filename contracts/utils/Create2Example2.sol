// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

// create2 - deterministically precompute contract address

contract Factory {
    event Deployed(address addr, uint256 salt);
    
    // 1. Get bytecode of contract to be deployed
    function getBytecode(address _owner, uint256 _foo) public pure returns (bytes memory) {
        bytes memory bytecode = type(TestContract).creationCode;
        // append contructor for deployment contract arguments to bytecode
        return abi.encodePacked(bytecode, abi.encode(_owner, _foo));
    }
    // 2. Compute the address of the contract to be deployed
    function getAddress(bytes memory bytecode, uint256 _salt) public view returns (address) {
        // keccak256(0xff + sender address + salt + keccak256(creation code))
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(bytecode)
            )
        );
        // last 20 bytes will be the address of contract being deployed
        // cast last 20 bytes of hash to address
        return address(uint160(uint256(hash)));
    }
    // 3. Deploy the contract
    function deploy(bytes memory bytecode, uint256 _salt) public payable {
        address addr;
        /* create2(v, p, n, s)
        v - amount of ETH to send
        p - pointer to start of code in memory
        n - size of code 
        s - salt
        */
        assembly {
            addr := create2(
                callvalue(), // wei sent with current call (msg.value)
                // actual code starts after skipping the first 32 bytes
                add(bytecode, 0x20),
                mload(bytecode), // load the size of code contained in the first 32 bytes
                _salt // salt from function call arguments
            )
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }
        emit Deployed(addr, _salt);
    }
}

contract TestContract {
    address public owner;
    uint256 public foo;

    constructor(address _owner, uint256 _foo) payable {
        owner = _owner;
        foo = _foo;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}