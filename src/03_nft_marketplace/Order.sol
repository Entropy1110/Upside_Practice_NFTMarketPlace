pragma solidity ^0.8.20;

struct Order {
    address exchange;
    address maker;
    address taker;
    OrderSide side;
    address erc721;
    uint256 tokenId;
    uint256 price;
    address paymentToken;
    uint16 feeRate;
    uint256 expirationTime;
    uint256 salt;
}

enum OrderSide {
    BUY,
    SELL
}
