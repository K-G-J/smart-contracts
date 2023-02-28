# @version ^0.2.0

"""
Receive Ether
"""

event Payment:
    sender: indexed(address)
    amount: uint256
    bal: uint256
    gasLeft: uint256

# declare payable default function
# default called when non-existing function is called on contract
# default called when only sending Ether to contract
@external
@payable
def __default__():
    log Payment(msg.sender, msg.value, self.balance, msg.gas)