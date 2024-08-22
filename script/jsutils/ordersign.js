const domainName = "Upside";
const version = "1.0";
const chainId = 31337;
const contractAddr = "0xB5A92EB54CD44C87875Ec8d4e166708ec6CCa61F";
const nftContractAddr = "0x0000000000000000000000000000000000010000";
const feeRecipient = "0x7777777777777777777777777777777777777777";
const signer = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
const buyer = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
const seller = "0x2222222222222222222222222222222222222222";

const order = {
    exchange: contractAddr,
    maker: buyer,
    taker: seller,
    makerRelayerFee: 0,
    takerRelayerFee: 0,
    makerProtocolFee: 250,
    takerProtocolFee: 0,
    feeRecipient: feeRecipient,
    feeMethod: 0,
    side: 0,
    saleKind: 0,
    target: nftContractAddr,
    howToCall: 0,
    calldata_: "0x42842e0e22222222222222222222222222222222222222220000000000000000000000000000000000000000",
    replacementPattern: "0x000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
    staticTarget: "0x0000000000000000000000000000000000000000",
    staticExtradata: "0x",
    paymentToken: "0x0000000000000000000000000000000000000000",
    basePrice: 1000,
    extra: 0,
    listingTime: 0,
    expirationTime: 0,
    salt: 12345
};

await window.ethereum.request({
    "method": "eth_signTypedData_v4",
    "params": [
        signer,
        {
            "types": {
                "EIP712Domain": [
                    {
                        "name": "name",
                        "type": "string"
                    },
                    {
                        "name": "version",
                        "type": "string"
                    },
                    {
                        "name": "chainId",
                        "type": "uint256"
                    },
                    {
                        "name": "verifyingContract",
                        "type": "address"
                    }
                ],
                "Order": [
                    {
                        "name": "exchange",
                        "type": "address"
                    },
                    {
                        "name": "maker",
                        "type": "address"
                    },
                    {
                        "name": "taker",
                        "type": "address"
                    },
                    {
                        "name": "makerRelayerFee",
                        "type": "uint256"
                    },
                    {
                        "name": "takerRelayerFee",
                        "type": "uint256"
                    },
                    {
                        "name": "makerProtocolFee",
                        "type": "uint256"
                    },
                    {
                        "name": "takerProtocolFee",
                        "type": "uint256"
                    },
                    {
                        "name": "feeRecipient",
                        "type": "address"
                    },
                    {
                        "name": "feeMethod",
                        "type": "uint8"
                    },
                    {
                        "name": "side",
                        "type": "uint8"
                    },
                    {
                        "name": "saleKind",
                        "type": "uint8"
                    },
                    {
                        "name": "target",
                        "type": "address"
                    },
                    {
                        "name": "howToCall",
                        "type": "uint8"
                    },
                    {
                        "name": "calldata_",
                        "type": "bytes"
                    },
                    {
                        "name": "replacementPattern",
                        "type": "bytes"
                    },
                    {
                        "name": "staticTarget",
                        "type": "address"
                    },
                    {
                        "name": "staticExtradata",
                        "type": "bytes"
                    },
                    {
                        "name": "paymentToken",
                        "type": "address"
                    },
                    {
                        "name": "basePrice",
                        "type": "uint256"
                    },
                    {
                        "name": "extra",
                        "type": "uint256"
                    },
                    {
                        "name": "listingTime",
                        "type": "uint256"
                    },
                    {
                        "name": "expirationTime",
                        "type": "uint256"
                    },
                    {
                        "name": "salt",
                        "type": "uint256"
                    },
                ]
            },
            "primaryType": "Order",
            "domain": {
                "name": domainName,
                "version": version,
                "chainId": chainId,
                "verifyingContract": contractAddr,
            },
            "message": order,
        }
    ]
});