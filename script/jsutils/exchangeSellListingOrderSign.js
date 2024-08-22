const domainName = "Upside NFT Exchange";
const version = "1";
const chainId = 31337;
const contractAddr = "0x8438Ad1C834623CfF278AB6829a248E37C2D7E3f";
const nftContractAddr = "0xBC9129Dc0487fc2E169941C75aABC539f208fb01";
const signer = "0x90F79bf6EB2c4f870365E785982E1f101E93b906";
const buyer = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC";
const seller = "0x90F79bf6EB2c4f870365E785982E1f101E93b906";

const order = {
    exchange: contractAddr,
    maker: seller,
    taker: "0x0000000000000000000000000000000000000000",
    side: 1,
    erc721: nftContractAddr,
    tokenId: 1,
    price: 1000,
    paymentToken: "0x0000000000000000000000000000000000000000",
    feeRate: 250,
    expirationTime: 0,
    salt: 12345,
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
                        "name": "side",
                        "type": "uint8"
                    },
                    {
                        "name": "erc721",
                        "type": "address"
                    },
                    {
                        "name": "tokenId",
                        "type": "uint256"
                    },
                    {
                        "name": "price",
                        "type": "uint256"
                    },
                    {
                        "name": "paymentToken",
                        "type": "address"
                    },
                    {
                        "name": "feeRate",
                        "type": "uint16"
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