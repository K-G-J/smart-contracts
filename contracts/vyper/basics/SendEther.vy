# @version ^0.2.0

"""
send Ether from contract to another address
"""

# use function "send" to send Ether from contract to another address
# first param is account to send Ether to and second is amount to send
# calls __default__ when Ether sent to contract
# send forwards 2300 gas

# Ether is transferred from EOA -> this contract -> to address
@external
@payable
def sendEther(to: address):
    send(to, msg.value)