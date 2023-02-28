# @version ^0.2.0

"""
interface (used for contract to contract interaction)
- call other functions (vie, nonpayable and payable, func does not exist)
- security
    - any address can be passed to interface and attack
    - use validation and protections before allowing address to call other functions on contract
"""
event Log:
    sender: indexed(address)
    message: String[100]

event Payment:
    sender: indexed(address)
    amount: uint256

# calling a function that does not exist (default is called)
@external
def __default__():
    log Log(msg.sender, "function does not exist")

# calling view function
@external
@view
def getBalance() -> uint256:
    return self.balance

# calling a nonpayable function
@external
def callMe(message: String[10]) -> uint256:
    log Log(msg.sender, message)
    return 123

# calling a payable function
@external
@payable
def pay():
    log Payment(msg.sender, msg.value)
