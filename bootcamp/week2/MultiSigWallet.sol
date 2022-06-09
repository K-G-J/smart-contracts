//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

error NotOwner();
error invalidRequired();
error AlreadyOwner();
error txDoesNotExist();
error txAlreadyExecuted();
error txAlreadyApproved();
error OwnerNotAlreadyApproved();
error lessThanRequiredConfirmations();
error txFailed();

contract MultiSigWallet {

    event Deposit(address sender, uint256 value, uint256 balance);
    event SubmittedTx(address to, uint256 value, bytes data);
    event ApprovedTx(address approver, uint256 txId);
    event RevokedApproval(address revoker, uint256 txId);
    event ExecuteTx(address to, uint256 value, uint256 txId, address executor);

    mapping (address => bool) public isOwner;

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
    uint256 public required;
    uint256 public txId;

    modifier onlyOwner() {
        if (!isOwner[msg.sender]) {
            revert NotOwner();
        }
        _;
    }

    modifier txExists(uint256 _txId) {
        if (transactions[txId].id > txId) {
            revert txDoesNotExist();
        }
        _;
    }

    modifier notExecuted(uint256 _txId) {
        if (transactions[_txId].executed) {
            revert txAlreadyExecuted();
        }
        _;
    }

    modifier notApproved(uint256 _txId) {
        if(approved[_txId][msg.sender]) {
            revert txAlreadyApproved();
        }
        _;
    }

    constructor (uint256 _required, address[] memory _owners) {
        if (_required > _owners.length) {
            revert invalidRequired();
        }
        for(uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            if(isOwner[owner]) {
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

    function approveTx(uint256 _txId) external onlyOwner txExists(_txId) notExecuted(_txId) notApproved(_txId) {
        transactions[_txId].confirmations++;
        approved[_txId][msg.sender] = true;
        emit ApprovedTx(msg.sender, _txId);
    }

    function executeTx(uint256 _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        Transaction storage transaction = transactions[_txId];
        if (transaction.confirmations < required) {
            revert lessThanRequiredConfirmations();
        }
        transaction.executed = true;
        (bool success, ) = payable(transaction.to).call{value: transaction.value}(transaction.data);
        if (!success) {
            revert txFailed();
        }
        emit ExecuteTx(transaction.to, transaction.value, _txId, msg.sender);
    }

    function revokeTx(uint256 _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        if(approved[_txId][msg.sender]) {
            approved[_txId][msg.sender] = false;
            transactions[_txId].confirmations --;
            emit RevokedApproval(msg.sender, _txId);
        } else {
            revert OwnerNotAlreadyApproved();
        }
    }
}