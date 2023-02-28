# @version ^0.2.0

num: public(uint256)
message: public(String[10])
value: public(uint256)
owner: public(address)

# payable constructor
@external
@payable
def __init__():
  self.owner = msg.sender
  self.value = msg.value

# basic example
@external # func can be called from outside contract
@pure # read only
def simple(x: uint256, b: bool, s: String[10]) -> (uint256, bool, String[100]):
  return (x + 1, not b, concat(s, "?"))

# visibility (who can call this function)
# visibilities: internal or external

# internal - can only be called from inside this contract
@internal 
@pure # read only
def intFunc(x: uint256, y: uint256) -> (uint256, bool):
  return (x + y, True)

# external - can only be called from outside this contract
@external
@view # read only
def extFunc(x: uint256) -> uint256:
  i: uint256 = 1
  b: bool = False
  # capture the output
  (i, b) = self.intFunc(1, 2) # will compile since internal function
  return x * x

# mutability (write to the blockchain or not)
# types of mutabilities: pure, view, nonpayable, payable
# pure does not read any state or environment variables but view does
# nonpayable - func does not accept any Ether
# payable - func can accept Ether
@external
@pure # does not read any state or environment variables or write to the blockchain
def pureFunc(x: uint256) -> bool:
  return x > 2

@external
@view # reads a state and environment variable
def viewFunc(x: uint256) -> (uint256, address):
  return(x + self.num, msg.sender)

@external # not pure, view, or payable
def writeSomething(_message: String[10]):
  # function writes to the blockchain and returns nothing
  self.message = _message

# can accept Ether
@external
@payable
def receiveEther():
  self.value = msg.value