pragma solidity ^0.8.20;

import {Order} from "./Order.sol";
import {Signature} from "./Signature.sol";

contract OrderValidator {
    function domainSeparator() external view returns (bytes32) {
        // TODO: Assignment #1
        return bytes32(0);
    }

    function orderTypeHash() external view returns (bytes32) {
        // TODO: Assignment #2
        return bytes32(0);
    }

    function hashOrder(Order memory order) public view returns (bytes32) {
        // TODO: Assignment #3
        return bytes32(0);
    }

    function hashToSign(Order memory order) public view returns (bytes32) {
        // TODO: Assignment #4
        return bytes32(0);
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
