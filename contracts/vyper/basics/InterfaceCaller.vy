# @version ^0.2.0

# define interface
interface Receiver:
    # function signature: function type
    def getBalance() -> uint256: view
    def callMe(message: String[10]) -> uint256: nonpayable
    def pay(): payable
    def doesNotExist(): nonpayable

## how to call function on another contract ##
# need defined interface and address of other contract

@external
@view
def getBalanceOfReceiver(receiver: address) -> uint256:
    return Receiver(receiver).getBalance()

@external
def callReceiver(receiver: address):
    num: uint256 = Receiver(receiver).callMe("hello")

# transfer ETH from EOA -> this contract -> Receiver contract
@external
@payable # needs to be payable to receive Ether from EOA
def payReceiver(receiver: address):
    # how to send Ether in function call
    Receiver(receiver).pay(value=msg.value)

@external
def callDoesNotExist(receiver: address):
    # this will call Receiver __default__
    Receiver(receiver).doesNotExist()