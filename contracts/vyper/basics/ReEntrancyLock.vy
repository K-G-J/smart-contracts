# @version ^0.2.0

# Re-entrancy lock #

event Log:
    message: String[100]

# hand craft a re-entrancy lock
locked: bool

@external
def func():
    assert not self.locked, "locked"
    self.locked = True # first set to True so if msg.sender tries to renter before rest of code finishes,will fail assert
    # do stuff here
    # call external contract, for example do raw_call to call default function
    raw_call(msg.sender, b"", value=0)
    # more code here
    self.locked = False

# examples of built in @nonreentrant
@external
@nonreentrant("lock") # name of lock in ()
def callMe():
    log Log("HERE")
    # call back msg.sender
    raw_call(msg.sender, b"", value=0)

@external
@nonreentrant("lock 2") # giving different names to locks allows functions to have different revert reasons
def callMe2():
    log Log("HERE HERE")
    # call back msg.sender
    raw_call(msg.sender, b"", value=0)