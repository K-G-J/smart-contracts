# @verion ^0.2.0

"""
Events
- examples
    - user interface
    - cheap storage (cannot access inside smart contracts)
"""
event Transfer:
    sender: indexed(address) # indexed allows for quick filtering event for a particular value (up to 3 indexed args allowed per event)
    receiver: indexed(address)
    value: uint256

event Authorized:
    addr: indexed(address)
    authorized: bool

@external
def transfer(to: address, amount:uint256):
    # transfer logic here ...
    log Transfer(msg.sender, to, amount)

# example of cheap storage
authorized: public(HashMap[address, bool])

@external
def grantAuthorization(addr: address):
    assert self.authorized[msg.sender], "!authorized"
    self.authorized[addr] = True
    log Authorized(addr, True)

@external
def revokeAuthorization(addr: address):
    assert self.authorized[msg.sender], "!authorized"
    self.authorized[addr] = False
    log Authorized(addr, False)

# 1. get all authorized events from earliest to latest block
# 2. after looping through all authorized events, created list of addresses for authorized and unauthorized