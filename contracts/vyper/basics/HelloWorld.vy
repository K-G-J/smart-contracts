# @version ^0.2.0

# variable is greet and it is a public string of max length 100
greet: public(String[100])

@external
def __init__():
  self.greet = "Hello World"
