pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ICounterV2} from "./ICounterV2.sol";

// TODO: Assignment #1
contract CounterV2 {
    // TODO: 변수가 올바르게 선언되었는지 확인해본다.

    // 컨트랙트 등록 시 block.timestamp 저장. (2주가 지나야 등록된 컨트랙트로 업그레이드 가능)
    mapping(address => uint256) registeredUpgradeContracts;

    // 카운터 변수
    uint256 public counter;

    function increment() external {
        // TODO: 카운트를 1 증가시킨다.
    }

    function reset() external {
        // TODO: Assignment #2
    }

    function registerUpgradingContract(address addr) external {
        // TODO: Assignment #3
    }

    function revokeUpgradingContract(address addr) external {
        // TODO: Assignment #3
    }
}
