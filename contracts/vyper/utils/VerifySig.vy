# @version ^0.2.0

# Signature verification

"""
1. hash a message to sign
2. sign message hash offchain
3. verify signature on chain
"""

# hash a message to sign
@external
@pure
def getHash(_str: String[100]) -> bytes32:
    return keccak256(_str)

# verify signature on chain
@external
@pure
def getEthSignedHash(_hash: bytes32) -> bytes32:
    return keccak256(
        concat(
            b'\x19Ethereum Signed Message:\n32', # prefix 
            _hash # hash from message to sign
        )
    )

@external
@pure
def verify(_ethSignedHash: bytes32, _sig: Bytes[65]) -> address:
    r: uint256 = convert(slice(_sig, 0, 32), uint256) # first 32 bytes of signature
    s: uint256 = convert(slice(_sig, 32, 32), uint256) # second 32 bytes
    v: uint256 = convert(slice(_sig, 64, 1), uint256) # last byte of the signature
    return ecrecover(_ethSignedHash, v, r, s)