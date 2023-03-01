# @version 0.2

interface DeployMe:
    def setup(name: String[100]): nonpayable

# built in function create_forwarder_to takes address of masterCopy(original contract) to deploy new contract copies from
# returns address of new contract copy
# saves significant gas 
@external
def deploy(_masterCopy: address, _name: String[100]) -> address:
    addr: address = create_forwarder_to(_masterCopy)
    # __init__ function on copies not called so need to use setup to set what would be in the __init__ function
    DeployMe(addr).setup(_name)
    return addr