# @version ^0.2.0

x: public(String[10])
owner: public(address)

@external
def __init__():
    self.owner = msg.sender



# state changes are reverted

# assert and raise
# error bubbles up
@internal
def _setX(sender: address, _x: String[10]):
    # expression that should be true followed by error message if expression found not to be true
    assert self.owner == sender, "!owner"

    # raise does same as assert
    if self.owner != sender:
        raise "!owner"

    self.x = _x

@external
def setX(_x: String[10]):
    self._setX(msg.sender, _x)

@external
def setXtoFoo():
    self._setX(msg.sender, "Foo")
    self.x = "Bar" # state variable does not get set if it fails the assert


# UNREACHABLE - uses all of gas
@external
def unreachable():
    raise UNREACHABLE # throws error with message "unreachable" which tells Vyper to use all of the gas