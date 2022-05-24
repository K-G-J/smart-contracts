//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {
    event Deposit(address indexed account, uint amount);
    event Withdraw (address indexed account, uint amount);

    constructor() ERC20("Wrapped Ether", "WETH") {}

    fallback() external payable {
        deposit();
    }

    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint _amount) external {
        _burn(msg.sender, _amount);
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require (success, "withdraw failed");
        emit Withdraw(msg.sender, _amount);
    }
}