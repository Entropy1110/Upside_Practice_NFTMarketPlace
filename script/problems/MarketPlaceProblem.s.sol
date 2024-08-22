pragma solidity ^0.8.20;

import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";
import {Problem} from "../utils/Problem.s.sol";
import {Exchange} from "../../src/03_nft_marketplace/Exchange.sol";
import {Order, OrderSide} from "../../src/03_nft_marketplace/Order.sol";
import {Signature} from "../../src/03_nft_marketplace/Signature.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {TestERC721} from "../utils/TestERC721.sol";
import {TestERC20} from "../utils/TestERC20.sol";

contract MarketPlaceProblem is Problem {
    address private constant feeRecipientAddr = 0x7777777777777777777777777777777777777777;
    address private constant sellListingContractAddr = 0x8438Ad1C834623CfF278AB6829a248E37C2D7E3f;
    address private constant sellListingErc721Addr = 0xBC9129Dc0487fc2E169941C75aABC539f208fb01;

    address private constant offerTestMarketContractAddr = 0x8cDbD76bB6Cf0293e07deEEEd460cf579873aF44;
    address private constant offerTestERC721Addr = 0xE7C2a73131dd48D8AC46dCD7Ab80C8cbeE5b410A;
    address private constant offerTestERC20Addr = 0x6cffa31dd31cF649fb24AC7cEfE87579324bD89c;

    constructor(Vm vm_) Problem(vm_) {}

    function description() public pure override returns (string memory) {
        return unicode"NFT Market 테스트";
    }

    function problems() internal override {
        problem(1, unicode"hashOrder - 성공 테스트");
        problem(2, unicode"isMatchable - 성공 테스트");
        problem(3, unicode"isMatchable - 같은 ERC721 토큰이어야 한다.");
        problem(4, unicode"isMatchable - 같은 ERC20 또는 Native Token 이어야 한다.");
        problem(5, unicode"isMatchable - 하나는 BUY, 하나는 SELL 주문이어야 한다");
        problem(6, unicode"isMatchable - 거래 가격 및 수수료율이 동일해야 한다");
        problem(7, unicode"Sell Listing => Buy Now 거래 - 성공 테스트");
        problem(8, unicode"Sell Listing => Buy Now 거래 - NFT 이동 확인");
        problem(9, unicode"Sell Listing => Buy Now 거래 - Native Token 이동 확인");
        problem(10, unicode"Sell Listing => Buy Now 거래 - 수수료 이동 확인");
        problem(11, unicode"Sell Listing => Buy Now 거래 - 사용한 주문은 재사용 불가능");
        problem(12, unicode"Offer => Sell 거래 - 성공 테스트");
        problem(13, unicode"Offer => Sell 거래 - NFT 이동 확인");
        problem(14, unicode"Offer => Sell 거래 - ERC20 이동 확인");
        problem(15, unicode"Offer => Sell 거래 - Native Token 이동 확인");
        problem(16, unicode"Offer => Sell 거래 - 기존 거래는 더 이상 사용 불가능");
    }

    function _assess() internal override {
        changeAccountContext("PRIVATE_KEY_3");

        _assess__hashOrder();
        _assess__matchable();
        _assess__sell_listing();
        _assess__offer_sell();
    }

    function _assess__hashOrder() internal {
        Exchange ex = new Exchange(250, feeRecipientAddr);

        address maker = vm.addr(vm.envUint("PRIVATE_KEY_3"));

        Order memory buyOrder = Order({
            exchange: address(ex),
            maker: maker,
            taker: address(0),
            side: OrderSide.BUY,
            erc721: address(this),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        bytes32 orderHash = ex.hashOrder(buyOrder);
        succeed(1, orderHash == bytes32(0xea3b0dd19ab4442b6c56712c845d26d98b3f6f9c8c57460b13239fe6fab743a8));
    }

    function _assess__matchable() internal {
        Exchange ex = new Exchange(250, address(this));

        _assess__matchable__should_be_match(ex);
        _assess__matchable__should_be_same_erc721(ex);
        _assess__matchable__should_be_same_token(ex);
        _assess__matchable__should_be_diff_side(ex);
        _assess__matchable__should_be_same_price_and_fee(ex);
    }

    function _assess__sell_listing() internal {
        Exchange ex = new Exchange(250, feeRecipientAddr);
        TestERC721 erc721 = new TestERC721();

        _assess__sell_listing_should_be_success(ex, erc721);
    }

    function _assess__offer_sell() internal {
        Exchange ex = new Exchange(500, feeRecipientAddr);
        TestERC721 erc721 = new TestERC721();
        TestERC20 erc20 = new TestERC20();

        _assess__offer_should_be_success(ex, erc721, erc20);
    }

    function _assess__matchable__should_be_match(Exchange ex) internal {
        address buyer = vm.addr(vm.envUint("PRIVATE_KEY_3"));
        address seller = vm.addr(vm.envUint("PRIVATE_KEY_4"));

        Order memory buy = Order({
            exchange: address(ex),
            maker: buyer,
            taker: address(0),
            side: OrderSide.BUY,
            erc721: address(0x01),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        Order memory sell = Order({
            exchange: address(ex),
            maker: seller,
            taker: buyer,
            side: OrderSide.SELL,
            erc721: address(0x01),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        succeed(2, ex.isMatchable(buy, sell));
    }

    function _assess__matchable__should_be_same_erc721(Exchange ex) internal {
        address buyer = vm.addr(vm.envUint("PRIVATE_KEY_3"));
        address seller = vm.addr(vm.envUint("PRIVATE_KEY_4"));

        Order memory buy = Order({
            exchange: address(ex),
            maker: buyer,
            taker: address(0),
            side: OrderSide.BUY,
            erc721: address(0x01),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        Order memory sell1 = Order({
            exchange: address(ex),
            maker: seller,
            taker: buyer,
            side: OrderSide.SELL,
            erc721: address(0x01),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        Order memory sell2 = Order({
            exchange: address(ex),
            maker: seller,
            taker: buyer,
            side: OrderSide.SELL,
            erc721: address(0x02),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        Order memory sell3 = Order({
            exchange: address(ex),
            maker: seller,
            taker: buyer,
            side: OrderSide.SELL,
            erc721: address(0x01),
            tokenId: 2,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        succeed(3, ex.isMatchable(buy, sell1) && !ex.isMatchable(buy, sell2) && !ex.isMatchable(buy, sell3));
    }

    function _assess__matchable__should_be_same_token(Exchange ex) internal {
        address buyer = vm.addr(vm.envUint("PRIVATE_KEY_3"));
        address seller = vm.addr(vm.envUint("PRIVATE_KEY_4"));

        Order memory buy = Order({
            exchange: address(ex),
            maker: buyer,
            taker: address(0),
            side: OrderSide.BUY,
            erc721: address(0x01),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        Order memory sell1 = Order({
            exchange: address(ex),
            maker: seller,
            taker: buyer,
            side: OrderSide.SELL,
            erc721: address(0x01),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        Order memory sell2 = Order({
            exchange: address(ex),
            maker: seller,
            taker: buyer,
            side: OrderSide.SELL,
            erc721: address(0x01),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0x1234),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        succeed(4, ex.isMatchable(buy, sell1) && !ex.isMatchable(buy, sell2));
    }

    function _assess__matchable__should_be_diff_side(Exchange ex) internal {
        address buyer = vm.addr(vm.envUint("PRIVATE_KEY_3"));
        address seller = vm.addr(vm.envUint("PRIVATE_KEY_4"));

        Order memory buy = Order({
            exchange: address(ex),
            maker: buyer,
            taker: buyer,
            side: OrderSide.BUY,
            erc721: address(0x01),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        Order memory sell = Order({
            exchange: address(ex),
            maker: buyer,
            taker: buyer,
            side: OrderSide.SELL,
            erc721: address(0x01),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        Order memory buy2 = Order({
            exchange: address(ex),
            maker: buyer,
            taker: buyer,
            side: OrderSide.BUY,
            erc721: address(0x01),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        succeed(5, ex.isMatchable(buy, sell) && !ex.isMatchable(buy, buy2));
    }

    function _assess__matchable__should_be_same_price_and_fee(Exchange ex) internal {
        address buyer = vm.addr(vm.envUint("PRIVATE_KEY_3"));
        address seller = vm.addr(vm.envUint("PRIVATE_KEY_4"));

        Order memory buy = Order({
            exchange: address(ex),
            maker: buyer,
            taker: address(0),
            side: OrderSide.BUY,
            erc721: address(0x01),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        Order memory sell1 = Order({
            exchange: address(ex),
            maker: seller,
            taker: buyer,
            side: OrderSide.SELL,
            erc721: address(0x01),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        Order memory sell2 = Order({
            exchange: address(ex),
            maker: seller,
            taker: buyer,
            side: OrderSide.SELL,
            erc721: address(0x01),
            tokenId: 1,
            price: 1001,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 0
        });

        Order memory sell3 = Order({
            exchange: address(ex),
            maker: seller,
            taker: buyer,
            side: OrderSide.SELL,
            erc721: address(0x01),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 100,
            expirationTime: 0,
            salt: 0
        });

        succeed(6, ex.isMatchable(buy, sell1) && !ex.isMatchable(buy, sell2) && !ex.isMatchable(buy, sell3));
    }

    function _assess__sell_listing_should_be_success(Exchange ex, TestERC721 erc721) internal {
        address buyer = vm.addr(vm.envUint("PRIVATE_KEY_3"));
        address seller = vm.addr(vm.envUint("PRIVATE_KEY_4"));

        try erc721.mintTo(seller, 1) {} catch {}
        changeAccountContext("PRIVATE_KEY_4");
        try erc721.setApprovalForAll(address(ex), true) {} catch {}

        uint256 prevBalance = seller.balance;
        uint256 prevFeeReceiverBalance = feeRecipientAddr.balance;

        Order memory buy = Order({
            exchange: address(ex),
            maker: buyer,
            taker: seller,
            side: OrderSide.BUY,
            erc721: address(erc721),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 4321
        });

        Signature memory buySig = Signature({
            r: hex"57cb74b103d04f8f2bdf429403ea5dd766f6df13a08f1baf03e567c392400ff3",
            s: hex"7fdd435978de05c28d5be08e3fb2eb7de123e46c90d6e0a004d78047a2ccdd95",
            v: 0x1b
        });

        Order memory sell = Order({
            exchange: address(ex),
            maker: seller,
            taker: address(0),
            side: OrderSide.SELL,
            erc721: address(erc721),
            tokenId: 1,
            price: 1000,
            paymentToken: address(0),
            feeRate: 250,
            expirationTime: 0,
            salt: 12345
        });

        Signature memory sellSig = Signature({
            r: hex"e94c9950d14b87e0017ed48118e03e7a382a57525f7d3eea9c791da4eb3cf5a3",
            s: hex"2da77b621f543227497e60118264dccf08dc8b285726c4b19bcb865bd1aa4149",
            v: 0x1c
        });

        changeAccountContext("PRIVATE_KEY_3");
        try ex.atomicMatch{value: 1000}(buy, buySig, sell, sellSig) {
            succeed(7, true);

            unchecked {
                succeed(8, erc721.ownerOf(1) == buyer);
                succeed(9, seller.balance - prevBalance == 975);
                succeed(10, feeRecipientAddr.balance - prevFeeReceiverBalance == 25);
            }

            try erc721.transferFrom(buyer, seller, 1) {} catch {}
            try ex.atomicMatch{value: 1000}(buy, buySig, sell, sellSig) {}
            catch {
                succeed(11, true);
            }
        } catch {}
    }

    function _assess__offer_should_be_success(Exchange ex, TestERC721 erc721, TestERC20 erc20) internal {
        address buyer = vm.addr(vm.envUint("PRIVATE_KEY_3"));
        address seller = vm.addr(vm.envUint("PRIVATE_KEY_4"));

        changeAccountContext("PRIVATE_KEY_3");
        try erc20.mintTo(buyer, 100000) {} catch {}
        try erc20.approve(address(ex), 100000) {} catch {}

        changeAccountContext("PRIVATE_KEY_4");
        try erc721.mintTo(seller, 2) {} catch {}
        try erc721.setApprovalForAll(address(ex), true) {} catch {}

        uint256 prevBalance = erc20.balanceOf(seller);
        uint256 prevFeeReceiverBalance = erc20.balanceOf(feeRecipientAddr);

        Order memory buy = Order({
            exchange: address(ex),
            maker: buyer,
            taker: address(0),
            side: OrderSide.BUY,
            erc721: address(erc721),
            tokenId: 2,
            price: 40000,
            paymentToken: address(erc20),
            feeRate: 500,
            expirationTime: 0,
            salt: 0xabcd
        });

        Signature memory buySig = Signature({
            r: hex"14ad74f372a4ad768a06a1cd2f8a675af3b50625ba3b26ecdda0e023dee8e6bc",
            s: hex"2fdf42a37c9de2fbd21e42bf9b5be8128594301cfc2f99efaf9eb1ca09377d32",
            v: 0x1c
        });

        Order memory sell = Order({
            exchange: address(ex),
            maker: seller,
            taker: buyer,
            side: OrderSide.SELL,
            erc721: address(erc721),
            tokenId: 2,
            price: 40000,
            paymentToken: address(erc20),
            feeRate: 500,
            expirationTime: 0,
            salt: 0xddeec123
        });

        Signature memory sellSig = Signature({
            r: hex"628e57e151c29840f8f3566bf7e3c26039e8bee0a80601d82d55572999dd2b99",
            s: hex"491a1cd9ecb68ff6b4991d32e31d91b227f415983854444f56e9def217d242df",
            v: 0x1b
        });

        changeAccountContext("PRIVATE_KEY_4");
        try ex.atomicMatch(buy, buySig, sell, sellSig) {
            succeed(12, true);

            unchecked {
                succeed(13, erc721.ownerOf(2) == buyer);
                succeed(14, erc20.balanceOf(seller) - prevBalance == 38000);
                succeed(15, erc20.balanceOf(feeRecipientAddr) - prevFeeReceiverBalance == 2000);
            }

            changeAccountContext("PRIVATE_KEY_3");
            try erc721.transferFrom(buyer, seller, 2) {} catch {}

            changeAccountContext("PRIVATE_KEY_4");
            try ex.atomicMatch(buy, buySig, sell, sellSig) {}
            catch {
                succeed(16, true);
            }
        } catch {}
    }
}
