# @version ^0.2.0

## Control Flow ##
    # if else
    # for loop
    # break, continue, pass

nums: public(uint256[3])

@external
def __init__():
    # nums = [1, 2, 3]
    self.nums[0] = 1
    self.nums[1] = 2
    self.nums[2] = 3

@external
@pure
def ifElse(i: uint256) -> uint256:
    if i < 10:
        return 0
    elif i < 20:
        return 1
    else:
        return 2

# for loop (array literal, state variables, range)
@external
@view
def forLoop() -> (uint256, uint256, uint256, uint256):
    x: uint256 = 0
    for i in [1, 2, 3]:
        # have to explicitly say type and convert i
        x += convert(i, uint256)
    # loop through state variables
    y: uint256 = 0
    for i in self.nums:
        y += i # don't have to convert because nums type has been delcared
    
    # for loop using range
    z: uint256 = 0
    # runs the loop 10 times
    for i in range(10):
        z += 1
    
    # for loop using range
    w: uint256 = 0
    # value of i is from 1 - 9
    for i in range(1, 10):
        w = convert(i, uint256) # last value of i
    
    return (x, y, z, w)

# break, continue, pass
@external
@pure
def continueAndBreak() -> (uint256):
    x: uint256 = 0
    for i in [1, 2, 3, 4, 5]:
        if i < 3:
            continue # skip to next iteration (code below not executed)
        if i == 4:
            break # exits the loop
        x = convert(i, uint256)
    return x

# pass - declare function signature but not write anything inside function body
@external
def blank():
    pass # useful when declaring function and writing implementation later
