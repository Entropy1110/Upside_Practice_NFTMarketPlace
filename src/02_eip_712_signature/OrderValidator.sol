pragma solidity ^0.8.20;

import {Order} from "./Order.sol";
import {Signature} from "./Signature.sol";

contract OrderValidator{

    bytes32 public constant ORDER_TYPED_HASH = keccak256(abi.encodePacked("Order(address exchange,address maker,address taker,uint256 makerRelayerFee,uint256 takerRelayerFee,uint256 makerProtocolFee,uint256 takerProtocolFee,address feeRecipient,uint8 feeMethod,uint8 side,uint8 saleKind,address target,uint8 howToCall,bytes calldata_,bytes replacementPattern,address staticTarget,bytes staticExtradata,address paymentToken,uint256 basePrice,uint256 extra,uint256 listingTime,uint256 expirationTime,uint256 salt)"));
    function domainSeparator() external view returns (bytes32) {
        return _domainSeparator();
    }

    function _domainSeparator() internal view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("Upside"),
                keccak256("1.0"),
                31337,
                address(this)
            )
        );
    }

    function orderTypeHash() external view returns (bytes32) {
        return ORDER_TYPED_HASH;
    }

    function hashOrder(Order memory order) public view returns (bytes32) {
        bytes memory data1;
        bytes memory data2;
        bytes memory data3;
        {
            data1 = abi.encode(
                ORDER_TYPED_HASH,
                order.exchange,
                order.maker,
                order.taker,
                order.makerRelayerFee,
                order.takerRelayerFee,
                order.makerProtocolFee
            );
        }
        {
            data2 = abi.encode(
                order.takerProtocolFee,
                order.feeRecipient,
                order.feeMethod,
                order.side,
                order.saleKind,
                order.target,
                order.howToCall,
                keccak256(order.calldata_)
            );
        }
        {
            data3 = abi.encode(
                keccak256(order.replacementPattern),
                order.staticTarget,
                keccak256(order.staticExtradata),
                order.paymentToken,
                order.basePrice,
                order.extra,
                order.listingTime,
                order.expirationTime,
                order.salt
            );
        }
        return keccak256(abi.encodePacked(data1, data2, data3));
    }

    function hashToSign(Order memory order) public view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                _domainSeparator(),
                hashOrder(order)
            )
        );
    }

    function verifyOrder(Order memory order, Signature memory sig) external view returns (bool) {
        bytes32 msgHash = hashToSign(order);

        /* Prevent signature malleability and non-standard v values. */
        if (uint256(sig.s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return false;
        }
        if (sig.v != 27 && sig.v != 28) {
            return false;
        }

        /* recover via ECDSA, signed by maker (already verified as non-zero). */
        return ecrecover(msgHash, sig.v, sig.r, sig.s) == order.maker;
    }
}
