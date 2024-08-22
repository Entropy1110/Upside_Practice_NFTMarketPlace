# NFT Marketplace

# 개요

NFT Marketplace Contract 에서는 buy 와 sell 주문을 받아서 ERC20(또는 Native Token) 과 NFT 토큰을
트랜잭션 하나에서 스왑하게 해주는 컨트랙트이다.

# Requirements

과제에서는 좀 더 간소화된 형태로 NFT MarketPlace 를 구현해볼 것이다.

- 각 유저는 Exchange 컨트랙트에 ERC-20 및 ERC-721 을 Approve 하여 거래한다.
- 유저는 원하는 형태로 Order 구조체를 생성하여 서명한다.
- 주문에 대한 서명 검증이 들어간다.
- 구매자와 판매자의 주문이 서로 매칭되면 `atomicMatch` 함수를 호출하여 거래할 수 있다.
- 판매자가 먼저 판매 주문을 올리고, 거래를 하는 형태 (Sell Listing => Buy Now)
- 구매자가 먼저 소유자에게 판매 제안(Offer) 를 올리고, 판매자가 수락하여 거래를 하는 형태 (Offer => Sell)

# Assignments

## Assignment #1

```
`hashOrder` 함수에 이를 구현해보자.
```

- order 값을 EIP-712 의 hashStruct 를 수행한다. 
- order 구조체의 형태가 변경되어서는 안된다.

## Assignment #2

```
각 주문에 대해서 검증을 수행하는 `validateOrder` 함수를 구현해보자.
```

- 주문은 "이미 사용된 주문" 이 아니어야 합니다. 즉, 이미 거래된 주문을 재사용할 수 없어야 한다.
- 주문의 만료 시간(expirationTime) 이 지나서는 안된다.
- 주문의 만료 시간(expirationTime) 이 0 인 경우, 만료 시간이 없는 거래이다.
- 주문에 대한 서명 검증이 들어가야 한다.
- 주문에 대한 검증이 완료되면 EIP-712 의 hashStruct 값, 즉, 주문에 대한 해시값이 리턴되어야 한다.

## Assignment #3

```
buy, sell 두 개의 주문이 서로 매칭될 수 있는지 여부를 리턴하는 `isMatchable` 함수를 구현해보자.

```

- 두 개의 주문의 가격, 거래 수수료, 동일한 NFT 인지 등등을 확인해야 한다.

**offer 주문인 경우**

- 구매자가 판매자에게 특정 가격에 판매를 제안하는 거래이며,
- 판매자가 특정될 필요가 없으므로 offer buy 주문인 경우 taker (판매자) 의 주소가 0 일 수 있다.

**판매자가 먼저 판매를 리스팅하는 판매 주문인 경우**

- 판매자가 이 NFT 를 특정 가격에 판매를 하겠다는 거래이며, 
- 구매자가 특정될 필요가 없으므로 이 sell 주문에서는 taker (구매자) 의 주소가 0 일 수 있다.

## Assignment #4

```
transferFunds 함수를 구현해보자.

transferFunds 는 구매자 (buy order 의 maker) 가 판매자 (sell order 의 maker) 에게 ERC-20 또는 Native Token 을 전송한다.
```

- 수수료는 constructor 에서 생성된 feeRecipient 주소로 보낸다.
- 수수료를 제외한 나머지는 sell.maker 로 보낸다.
- Native Token 의 경우 Approve 기능이 없으므로 생길 수 있는 문제에 대해서도 생각해보고, 이를 해결하기 위한 방법에 대해서 생각해보자.

## Assignment #5

```
transferERC721 함수를 구현해보자.
```

- transferERC721 은 판매자 (sell order 의 maker) 가 구매자 (buy order 의 maker) 에게 ERC-721 토큰을 전송한다.

## Assignment #6

```
buy, sell 주문을 받아서 매칭하여, 코인과 NFT 를 거래하는 함수를 구현한다.
```

1. 각각 주문(buy, sell) 에 대한 검증
2. 두 개의 주문이 매칭될 수 있는가에 대한 검증
3. 두 개의 주문 만료 처리
4. ERC-20 (또는 Native Token) 을 구매자 => 판매자에게 이동 및 수수료 처리
5. ERC-721 을 판매자 => 구매자에게 전송
6. 이벤트 로그 생성 및 종료