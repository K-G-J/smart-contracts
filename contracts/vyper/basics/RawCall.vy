# @verzion ^0.2

event Log:
    message: String[100]
    val: uint256

@external
def callTest(test: address, x: uint256, y: uint256):
    # res = return value of calling the function
    res: Bytes[128] = raw_call(
        test, # contract addres
        # data
            # method id (first 4 bytes hash of func signature)
                # use method_id(function signature)
            # inputs
                # convert inputs to bytes32 because required to represent uint256
        concat(
            method_id("test(uint256,uint256,uint256[])"),
            convert(x, bytes32),
            convert(y, bytes32),
            convert(96, bytes32), # offset - where dynamic array starts, 3 func args * 32 = 96
            convert(2, bytes32), # length of uint256[]
            convert(88, bytes32), # uint256[0]
            convert(99, bytes32) # uint256[1]
        ),
        # max output size
        max_outsize=128
    )

    # parse output into data types we want by passing in raw output, starting position, and type
    offset: uint256 = extract32(res, 0, output_type=uint256) # offset
    l: uint256 = extract32(res, 32, output_type=uint256) # length
    y0: uint256 = extract32(res, 64, output_type=uint256) # first element of the array
    y1: uint256 = extract32(res, 96, output_type=uint256) # second element of the array

    # output follows same format as creating dynamic array
    # offset
    # length
    # element 0
    # element 1
    # in this example: each element is uint256 = 32 * 4 = 128

    log Log("offset", offset)
    log Log("length", l)
    log Log("y0", y0)
    log Log("y1", y1)
