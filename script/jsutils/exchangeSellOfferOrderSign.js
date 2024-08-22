const domainName = "Upside NFT Exchange";
const version = "1";
const chainId = 31337;
const contractAddr = "0x8cDbD76bB6Cf0293e07deEEEd460cf579873aF44";
const nftContractAddr = "0xE7C2a73131dd48D8AC46dCD7Ab80C8cbeE5b410A";
const signer = "0x90F79bf6EB2c4f870365E785982E1f101E93b906";
const buyer = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC";
const seller = "0x90F79bf6EB2c4f870365E785982E1f101E93b906";

const order = {
    exchange: contractAddr,
    maker: seller,
    taker: buyer,
    side: 1,
    erc721: nftContractAddr,
    tokenId: 2,
    price: 40000,
    paymentToken: "0x6cffa31dd31cF649fb24AC7cEfE87579324bD89c",
    feeRate: 500,
    expirationTime: 0,
    salt: 0xddeec123,
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