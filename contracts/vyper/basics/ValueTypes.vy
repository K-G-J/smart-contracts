# @version ^0.2.0

# declare public variable "b" that is a boolean
b: public(bool)

# datatype for both negative and positive numbers
i: public(int128) # 2 ** 127 to (2 ** 127 -1)

# datatype when only dealing with non-negative numbers
u: public(uint256) # 0 to 2 ** 256 -1

# supports up to 10 decimal places
d: public(decimal) # 2 ** 127 to (2 ** 127 -1)

# blockchain address
addr: public(address) # bytes32

# 32 bytes - cryptographic hash
b32: public(bytes32)

# bytes of max 100 length 
bs: public(Bytes[100])

# string of max 100 characters
s: public(String[100])

@external
def __init__():
  self.b = True
  self.i = -1
  self.u = 123
  self.d = 3.14
  self.addr = 0x0d02271bC48Aed2b9882D976fa1104ee52c61D28 # random address
  self.b32 = 0xada1b75f8ae9a65dcc16f95678ac203030505c6b465c8206e26ae84b525cdacb # random bytes32
  self.bs = b"\x01"
  self.s = "Hello Vyper"