# @version ^0.2.0

"""
state variables
    - public and private
- name shaddowing
- constants
    - built in
        - ZERO_ADDRESS
        - MAX_UINT256
    - custom
- environment variables
    - self.balance - amount of Ether in this contract
    - msg.sender - address that calls a function
    - msg.value - amount of Ether sent to a function
    - block.number - block that function was called
    - block.timestamp - timestamp in seconds that function was called
    - tx.origin - address of original function caller
"""

# state variables are stored on the blockchain
num: public(uint256) # public contract and other contracts can read
# private variable
# never store sensitive data on the blockchain
password: String[20] # other smart contracts cannot read this variable

@external
def __init__():
    self.num = 1
    self.password = "password123"

# name shadowing - when state and local variables have the same name, Vyper will NOT compile the code

# this will NOT compile
# @external
# def setNum(num: uint256):
#     self.num = num

# # this will also NOT compile
# @external
# def setNum(x: uint256):
#     num: uint256 = x + 1
#     self.num = num

# will NOT compile because balance is reserved keyword
# @external
# @view
# def dontDoThis() -> uint256:
#     balance: uint256 = 1
#     return balance

# constants
# value can never change 
MY_CONSTANT: constant(uint256) = 123

@external
@pure
def getBuiltInConstants() -> (address, uint256):
    return (ZERO_ADDRESS, MAX_UINT256)

# environment variables
@external
@payable
def returnEnvironmentVariables() -> (uint256, address, uint256, uint256, uint256, address):
    return (
        self.balance,
        msg.sender,
        msg.value,
        block.number,
        block.timestamp,
        tx.origin
    )

# msg.sender and tx.origin
# A - calls -> B - calls -> C
# inside contract C
    # msg.sender = B 
    # tx.origin = A