pragma solidity ^0.8.20;

import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";
import {Problem} from "../utils/Problem.s.sol";
import {Order, SaleKindInterface, HowToCall, FeeMethod} from "../../src/02_eip_712_signature/Order.sol";
import {Signature} from "../../src/02_eip_712_signature/Signature.sol";
import {OrderValidator} from "../../src/02_eip_712_signature/OrderValidator.sol";

contract EIP712Problem is Problem {
    OrderValidator validator1;
    OrderValidator validator2;
    bytes constant MAGIC_CODE =
        hex"8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400fac30090aa71ce013fc50827ebcf621423bd3d9012183f3da7f8a6ee9ec37c54be6bbd6277e1bf288eed5e8d1780f9a50b239e86b153736bceebccf4ea79d90b30000000000000000000000000000000000000000000000000000000000007a69";

    constructor(Vm vm_) Problem(vm_) {
        validator1 = new OrderValidator();
        validator2 = new OrderValidator();
    }

    function description() public pure override returns (string memory) {
        return unicode"EIP-712 테스트";
    }

    function problems() internal override {
        problem(1, unicode"Domain Separator 테스트");
        problem(2, unicode"다른 컨트랙트끼리 다른 Domain Separator 를 소유하는지 테스트");
        problem(3, unicode"typeHash 값이 일치하는지 확인");
        problem(4, unicode"다른 컨트랙트라도 동일한 구조체에 대해서는 같은 typeHash 값을 가지는지 테스트");
        problem(5, unicode"동일한 데이터라도 다른 컨트랙트끼리 다른 서명 메시지를 갖는지 테스트");
        problem(6, unicode"다른 데이터면 다른 서명 메시지를 갖는지 테스트");
        problem(7, unicode"EIP-712 서명 성공");
    }

    function _assess() internal override {
        bytes32 domainSeparator1 = keccak256(abi.encodePacked(MAGIC_CODE, uint256(uint160(address(validator1)))));
        bytes32 domainSeparator2 = keccak256(abi.encodePacked(MAGIC_CODE, uint256(uint160(address(validator2)))));

        succeed(1, domainSeparator1 == validator1.domainSeparator());
        succeed(2, validator1.domainSeparator() != validator2.domainSeparator());

        address buyer = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        address seller = 0x2222222222222222222222222222222222222222;
        address feeRecipient = 0x7777777777777777777777777777777777777777;
        address nftContractAddr = 0x0000000000000000000000000000000000010000;

        Order memory buyOrder = Order({
            exchange: address(validator1),
            maker: buyer,
            taker: seller,
            makerRelayerFee: 0,
            takerRelayerFee: 0,
            makerProtocolFee: 250,
            takerProtocolFee: 0,
            feeRecipient: feeRecipient,
            feeMethod: FeeMethod.ProtocolFee,
            side: SaleKindInterface.Side.Buy,
            saleKind: SaleKindInterface.SaleKind.FixedPrice,
            target: nftContractAddr,
            howToCall: HowToCall.Call,
            calldata_: hex"42842e0e22222222222222222222222222222222222222220000000000000000000000000000000000000000",
            replacementPattern: hex"000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            staticTarget: address(0),
            staticExtradata: hex"",
            paymentToken: address(0),
            basePrice: 1000,
            extra: 0,
            listingTime: 0,
            expirationTime: 0,
            salt: 12345
        });

        Order memory buyOrder2 = Order({
            exchange: address(validator2),
            maker: buyer,
            taker: seller,
            makerRelayerFee: 0,
            takerRelayerFee: 0,
            makerProtocolFee: 250,
            takerProtocolFee: 0,
            feeRecipient: feeRecipient,
            feeMethod: FeeMethod.ProtocolFee,
            side: SaleKindInterface.Side.Buy,
            saleKind: SaleKindInterface.SaleKind.FixedPrice,
            target: nftContractAddr,
            howToCall: HowToCall.Call,
            calldata_: hex"42842e0e22222222222222222222222222222222222222220000000000000000000000000000000000000000",
            replacementPattern: hex"000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            staticTarget: address(0),
            staticExtradata: hex"",
            paymentToken: address(0),
            basePrice: 1000,
            extra: 0,
            listingTime: 0,
            expirationTime: 0,
            salt: 12345
        });

        Order memory sellOrder = Order({
            exchange: address(validator1),
            maker: seller,
            taker: buyer,
            makerRelayerFee: 0,
            takerRelayerFee: 0,
            makerProtocolFee: 250,
            takerProtocolFee: 0,
            feeRecipient: feeRecipient,
            feeMethod: FeeMethod.ProtocolFee,
            side: SaleKindInterface.Side.Sell,
            saleKind: SaleKindInterface.SaleKind.FixedPrice,
            target: nftContractAddr,
            howToCall: HowToCall.Call,
            calldata_: hex"42842e0e22222222222222222222222222222222222222220000000000000000000000000000000000000000",
            replacementPattern: hex"00000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000000000000000",
            staticTarget: address(0),
            staticExtradata: hex"",
            paymentToken: address(0),
            basePrice: 1000,
            extra: 0,
            listingTime: 0,
            expirationTime: 0,
            salt: 12345
        });

        bytes32 orderTypeHash = hex"ca4377d906372522e7493b3d6fe70269bae292f170294366cdebf4bfe6f57dcf";
        succeed(3, validator1.orderTypeHash() == orderTypeHash);
        succeed(4, validator1.orderTypeHash() == validator2.orderTypeHash());

        bytes32 hashToSign1 = validator1.hashToSign(buyOrder);
        bytes32 hashToSign2 = validator2.hashToSign(buyOrder);

        succeed(5, hashToSign1 != hashToSign2);

        bytes32 sellHashToSign1 = validator1.hashToSign(sellOrder);

        succeed(6, hashToSign1 != sellHashToSign1);

        // buyOrder 를 "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" 주소로 서명한 값
        Signature memory sig = Signature({
            r: hex"31e0477aa43896d01d39366bd2efde469c04752258d701bcd792b2d9f7eec6c8",
            s: hex"32b1a4cd3609e7c910bbf2e6fece20ac765751c0d53d2b0b52e9207ddedfecf9",
            v: 0x1b
        });

        // buyOrder2 를 "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" 주소로 서명한 값
        Signature memory sig2 = Signature({
            r: hex"5f89f4374b69a56eac31c2f8215a257e84b5f0210cc0a21f9dc1f30ac8ec3f92",
            s: hex"238eefd60b7205c7ea46c2b70b3770483cf8e5707a1105049d86a4c8dbe0f3bf",
            v: 0x1c
        });

        succeed(7, validator1.verifyOrder(buyOrder, sig) && validator2.verifyOrder(buyOrder2, sig2));
    }
}
