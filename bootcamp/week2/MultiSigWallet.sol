// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

error InvalidNumRequired();
error InvalidOwnerAddress();
error AlreadyOwner();
error NotOwner();
error TxDoesNotExists();
error TxAlreadyExecuted();
error TxAlreadyApproved();
error TxNotApproved();
error LessConfirmationsThanRequired();
error TxExecutionFailed();

contract MultiSigWallet {
    event Deposit(address sender, uint256 value, uint256 balance);
    event SubmittedTx(address to, uint256 value, bytes data);
    event ApprovedTx(uint256 txId, address approver);

    mapping(address => bool) public isOwner;

    struct Transaction {
        uint256 id;
        address to;
        uint256 value;
        bytes data;
        uint256 confirmations;
        bool executed;
    }

    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public approved;

    uint256 required;
    uint256 txId;

    modifier onlyOwner() {
        if (!isOwner[msg.sender]) {
            revert NotOwner();
        }
        _;
    }

    modifier txExists(uint256 _txId) {
        if (_txId > txId) {
            revert TxDoesNotExists();
        }
        _;
    }

    modifier notExecuted(uint256 _txId) {
        if (transactions[_txId].executed) {
            revert TxAlreadyExecuted();
        }
        _;
    }

    modifier notApproved(uint256 _txId) {
        if (approved[_txId][msg.sender]) {
            revert TxAlreadyApproved();
        }
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        if (_required > _owners.length) {
            revert InvalidNumRequired();
        }
        for(uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            if (owner == address(0)) {
                revert InvalidOwnerAddress();
            }
            if (isOwner[owner]) {
                revert AlreadyOwner();
            }
            isOwner[owner] = true;
        }
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTx(address _to, uint256 _value, bytes memory _data) external onlyOwner {
        Transaction storage transaction = transactions[txId];
        transaction.id = txId;
        transaction.to = _to;
        transaction.value = _value;
        transaction.data = _data;
        txId++;
        emit SubmittedTx(_to, _value, _data);
    }

    function approveTx(uint256 _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
        transactions[_txId].confirmations++;
        approved[_txId][msg.sender] = true;
        emit ApprovedTx(_txId, msg.sender);
    }

    function executeTx(uint256 _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        Transaction storage transaction = transactions[_txId];
        if (transaction.confirmations < required) {
            revert LessConfirmationsThanRequired();
        }
        transaction.executed = true;
        (bool success, ) = payable(transaction.to).call{value: transaction.value}(transaction.data);
        if (!success) {
            revert TxExecutionFailed();
        }
    }

    function revokeTx(uint256 _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        if (approved[_txId][msg.sender]) {
            transactions[_txId].confirmations--;
            approved[_txId][msg.sender] = false;
        } else {
            revert TxNotApproved();
        }
    }
}