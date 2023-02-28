# @version ^0.2.0

"""
Reference types
- list
- mappings
- structs 
"""

# MUST specify the maximum length variables

# List
nums: public(uint256[10])

# Mapping
myMap: public(HashMap[address, uint256])

# Struct
struct Person:
  name: String[100]
  age: uint256

person: public(Person)

# Constructor
@external
def __init__():
  self.nums[5] = 123
  self.myMap[msg.sender] = 456
  self.person.name = "Vyper"

  arr: uint256[10] = self.nums
  # Does NOT modify nums[0]
  arr[0] = 999

  # Mappings cannot be local variable

  p: Person = self.person
  # Does NOT change name in the person struct
  p.name = "Solidity"