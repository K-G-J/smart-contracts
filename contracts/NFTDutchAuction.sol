// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC721 {
    function transferFrom(
        address from,
        address to,
        uint nftId
    ) external;
}

contract DutchAuction {
    uint private constant DURATION = 7 days;

    IERC721 public immutable nft;
    uint public immutable nftId;

    address payable public immutable seller;
    uint public immutable startingPrice;
    uint public immutable startAt;
    uint public immutable expiresAt;
    uint public immutable discountRate;
    bool public ended;

    modifier notEnded() {
        require(!ended, "auction ended");
        _;
    }

    constructor(uint _startingPrice, uint _discountRate, address _nft, uint _nftId) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;

        require(_startingPrice >= _discountRate * DURATION, "starting price < discount");

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    function getPrice() public view notEnded returns (uint) {
        uint timeElapsed = block.timestamp - startAt;
        uint discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable notEnded {
        require(block.timestamp < expiresAt, "auction expired");
        
        uint price = getPrice();
        require(msg.value >= price, "ETH < price");
        ended = true;
        nft.transferFrom(seller, msg.sender, nftId);
        uint refund = msg.value - price;
        if (refund > 0) {
            (bool success, ) = payable(msg.sender).call{value: refund}("");
            require(success, "refund failed");
        }
    }
}