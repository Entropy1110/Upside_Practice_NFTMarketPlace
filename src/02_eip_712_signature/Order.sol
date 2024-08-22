pragma solidity ^0.8.20;

enum FeeMethod {
    ProtocolFee,
    SplitFee
}

struct Order {
    address exchange;
    address maker;
    address taker;
    uint256 makerRelayerFee;
    uint256 takerRelayerFee;
    uint256 makerProtocolFee;
    uint256 takerProtocolFee;
    address feeRecipient;
    FeeMethod feeMethod;
    SaleKindInterface.Side side;
    SaleKindInterface.SaleKind saleKind;
    address target;
    HowToCall howToCall;
    bytes calldata_;
    bytes replacementPattern;
    address staticTarget;
    bytes staticExtradata;
    address paymentToken;
    uint256 basePrice;
    uint256 extra;
    uint256 listingTime;
    uint256 expirationTime;
    uint256 salt;
}

library SaleKindInterface {
    enum Side {
        Buy,
        Sell
    }

    enum SaleKind {
        FixedPrice,
        DutchAuction
    }
}

enum HowToCall {
    Call,
    DelegateCall
}
