# @version ^0.2.0

sender: public(address)
receiver: public(address)

DURATION: constant(uint256) = 7 * 24 * 60 * 60 # 7 days
expiresAt: public(uint256)

@external
@payable
def __init__(_receiver: address):
    assert _receiver != ZERO_ADDRESS, "receiver == 0 address"
    self.sender = msg.sender
    self.receiver = _receiver
    self.expiresAt = block.timestamp + DURATION # payment channel expires in 7 days after contract creation

@internal
@pure
def _getHash(_amount: uint256) -> bytes32:
    return keccak256(concat(
    convert(self, bytes32), # prevent signature replay attack by including address of this contract
    convert(_amount, bytes32)
    ))

@external
@view
def gethash(_amount: uint256) -> bytes32:
    return self._getHash(_amount)

@internal
@view
def _getEthSignedHash(_amount: uint256) -> bytes32:
    hash: bytes32 = self._getHash(_amount)
    return keccak256(
        concat(
            b'\x19Ethereum Signed Message:\n32',
            hash
        )
    )

@external
@view
def getEthSignedHash(_amount: uint256) -> bytes32:
    return self._getEthSignedHash(_amount)

@internal
@view
def _verify(_amount: uint256, _sig: Bytes[65]) -> bool:
    ethSignedHash: bytes32 = self._getEthSignedHash(_amount)

    r: uint256 = convert(slice(_sig, 0, 32), uint256) # first 32 bytes of sig
    s: uint256 = convert(slice(_sig, 32, 32), uint256) # second 32 bytes of sig
    v: uint256 = convert(slice(_sig, 64, 1), uint256) # last byte of sig

    return ecrecover(ethSignedHash, v, r, s) == self.sender

@external
@view
def verify(_amount: uint256, _sig: Bytes[65]) -> bool:
    return self._verify(_amount, _sig)

@nonreentrant("lock")
@external
def close(_amount: uint256, _sig: Bytes[65]):
    assert msg.sender == self.receiver, "!receiver"
    assert self._verify(_amount, _sig), "invalid sig"

    raw_call(self.receiver, b'\x00', value=_amount) # send to receiver, 0 bytes, and _amount of Eth
    selfdestruct(self.sender) # delete contract and send all leftover Eth in contract to sender

# function to call if there is a disagrement and payment channel is not closed by receiver so sender can get back all Eth locked in the contract after expiration
@external
def cancel():
    assert msg.sender == self.sender, "!sender"
    assert block.timestamp >= self.expiresAt, "!expired"
    selfdestruct(self.sender)