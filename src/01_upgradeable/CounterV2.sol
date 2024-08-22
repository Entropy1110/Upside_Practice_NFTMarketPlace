pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ICounterV2} from "./ICounterV2.sol";

// TODO: Assignment #1
contract CounterV2 is UUPSUpgradeable, OwnableUpgradeable, ICounterV2{
    // TODO: 변수가 올바르게 선언되었는지 확인해본다.
    uint256 public counter;
    // 컨트랙트 등록 시 block.timestamp 저장. (2주가 지나야 등록된 컨트랙트로 업그레이드 가능)
    mapping(address => uint256) registeredUpgradeContracts;

    function increment() external {
        counter++;
    }

    function reset() external {
        counter = 0;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {
        uint registerTime = registeredUpgradeContracts[newImplementation];
        require(registerTime < block.timestamp - 2 weeks && registerTime > 0);
        
    }

    function registerUpgradingContract(address addr) external onlyOwner{
        registeredUpgradeContracts[addr] = block.timestamp;
    }

    function revokeUpgradingContract(address addr) external onlyOwner{
        registeredUpgradeContracts[addr] = 0;
    }
}
