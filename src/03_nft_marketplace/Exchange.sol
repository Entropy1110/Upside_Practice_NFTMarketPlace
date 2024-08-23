pragma solidity ^0.8.20;

import {Order, OrderSide} from "./Order.sol";
import {Signature} from "./Signature.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 *   _   _           _     _          _   _ _____ _____     _____          _
 *  | | | |_ __  ___(_) __| | ___    | \ | |  ___|_   _|   | ____|_  _____| |__   __ _ _ __   __ _  ___
 *  | | | | '_ \/ __| |/ _` |/ _ \   |  \| | |_    | |     |  _| \ \/ / __| '_ \ / _` | '_ \ / _` |/ _ \
 *  | |_| | |_) \__ \ | (_| |  __/   | |\  |  _|   | |     | |___ >  < (__| | | | (_| | | | | (_| |  __/
 *   \___/| .__/|___/_|\__,_|\___|   |_| \_|_|     |_|     |_____/_/\_\___|_| |_|\__,_|_| |_|\__, |\___|
 *        |_|                                                                                |___/
 */
contract Exchange is EIP712, ReentrancyGuard, Ownable {
    uint256 internal constant BASE_POINT = 10000;
    uint256 minimumFeeRate;
    address feeRecipient;

    bytes32 private _ORDER_TYPE_HASH = keccak256(
        "Order(address exchange,address maker,address taker,uint8 side,address erc721,uint256 tokenId,uint256 price,address paymentToken,uint16 feeRate,uint256 expirationTime,uint256 salt)"
    );

    event OrdersMatched(
        bytes32 buyHash,
        bytes32 sellHash,
        address indexed buyer,
        address indexed seller,
        address indexed target,
        uint256 price
    );

    mapping(bytes32=>bool) orders;

    constructor(uint256 minimumFeeRate_, address feeRecipient_)
        EIP712("Upside NFT Exchange", "1")
        ReentrancyGuard()
        Ownable(_msgSender())
    {
        minimumFeeRate = minimumFeeRate_;
        feeRecipient = feeRecipient_;
    }

    /**
     * @dev match buy and sell order so that exchange ERC-20 or native token and ERC-721.
     */
    function atomicMatch(Order memory buy, Signature memory buySig, Order memory sell, Signature memory sellSig)
        external
        payable
        nonReentrant
    {
        // buy 와 sell 주문의 파라미터 및 서명 값을 검증하고, 주문에 대한 해시값을 가져옵니다.
        bytes32 buyHash = validateOrder(buy, buySig);
        bytes32 sellHash = validateOrder(sell, sellSig);

        require(!orders[buyHash] && !orders[sellHash], "no reusable");

        // 두 개의 주문은 서로 매칭될 수 있어야 합니다.
        require(isMatchable(buy, sell), "not matchable");

        
        transferERC721(buy, sell);

        transferFunds(buy, sell);

        orders[buyHash] = true;
        orders[sellHash] = true;

        // 거래가 완료된 후, 이벤트 로그를 생성하고 종료합니다.
        emit OrdersMatched(buyHash, sellHash, buy.maker, sell.maker, buy.erc721, buy.price);
    }

    /**
     * @dev 최소 수수료를 변경합니다.
     */
    function changeFeeRate(uint256 minimumFeeRate_) external onlyOwner {
        minimumFeeRate = minimumFeeRate_;
    }

    function validateOrder(Order memory order, Signature memory sig) internal view returns (bytes32) {
        bytes32 orderHash = hashToSign(order);

        require(ecrecover(orderHash, sig.v, sig.r, sig.s) == order.maker, "invalid signature");

        if (order.expirationTime > 0)
            require(order.expirationTime >= block.timestamp, "order expired");

        return orderHash;
    }

    function isMatchable(Order memory buy, Order memory sell) public view returns (bool) {
        return buy.side == OrderSide.BUY && sell.side == OrderSide.SELL && buy.erc721 == sell.erc721 && buy.tokenId == sell.tokenId && buy.price >= sell.price && buy.paymentToken == sell.paymentToken && buy.feeRate == sell.feeRate;
    }

    /*-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-*/

    /**
     * @dev buyer -> seller 에게 ERC20 또는 Native Token 을 전송합니다.
     */
    function transferFunds(Order memory buy, Order memory sell) internal {
        // address 가 0 일 때는 Native Token (ETH), 0이 아닐 때는 ERC20 토큰으로 처리됩니다.
        if (buy.paymentToken == address(0)) {
            transferNativeToken(buy, sell);
        } else {
            transferERC20(buy, sell);
        }
    }

    function transferERC20(Order memory buy, Order memory sell) internal {
        // feeRecipient.
        (uint256 price, uint256 fee) = calculateNetAmountAndFee(buy.price, buy.feeRate);
        address seller = buy.taker == address(0) ? sell.maker : buy.taker;
        address buyer = sell.taker == address(0) ? buy.maker : sell.taker;
        IERC20(buy.paymentToken).transferFrom(buyer, feeRecipient, fee);
        IERC20(buy.paymentToken).transferFrom(buyer, seller, price);
    }

    function transferNativeToken(Order memory buy, Order memory sell) internal {
        (uint256 price, uint256 fee) = calculateNetAmountAndFee(buy.price, buy.feeRate);
        address seller = buy.taker == address(0) ? sell.maker : buy.taker;
        address buyer = sell.taker == address(0) ? buy.maker : sell.taker;

        address(feeRecipient).call{value: fee}("");
        address(seller).call{value: price}("");

    }

    function calculateNetAmountAndFee(uint256 price, uint256 feeRate) internal view returns (uint256, uint256) {
        require(feeRate >= minimumFeeRate, "fee is too low");
        uint256 fee = price * feeRate / BASE_POINT;
        return (price - fee, fee);
    }

    /*-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-*/

    /**
     * @dev seller -> buyer 에게 ERC721 토큰을 전송합니다.
     */
    function transferERC721(Order memory buy, Order memory sell) internal {

        address seller = buy.taker == address(0) ? sell.maker : buy.taker;
        address buyer = sell.taker == address(0) ? buy.maker : sell.taker;
        
        IERC721(buy.erc721).safeTransferFrom(seller, buyer, buy.tokenId);

    }

    /*-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-*/

    function targetExists(address target) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(target)
        }
        return size > 0;
    }

    function hashOrder(Order memory order) public view returns (bytes32) {
        return keccak256(
            abi.encode(
                _ORDER_TYPE_HASH,
                order.exchange,
                order.maker,
                order.taker,
                order.side,
                order.erc721,
                order.tokenId,
                order.price,
                order.paymentToken,
                order.feeRate,
                order.expirationTime,
                order.salt
            )
        );
    }

    function hashToSign(Order memory order) public view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), hashOrder(order)));
    }
}
