pragma solidity ^0.8.20;

import {Vm} from "forge-std/Vm.sol";
import {Problem} from "../utils/Problem.s.sol";
import {CounterV1} from "../../src/01_upgradeable/CounterV1.sol";
import {ICounterV1} from "../../src/01_upgradeable/ICounterV1.sol";
import {CounterV2} from "../../src/01_upgradeable/CounterV2.sol";
import {ICounterV2} from "../../src/01_upgradeable/ICounterV2.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract UpgradeableProblem is Problem {
    bytes INIT_METHOD_ID = hex"8129fc1c";

    constructor(Vm vm_) Problem(vm_) {}

    function description() public pure override returns (string memory) {
        return unicode"CounterV1 => CounterV2 로 업그레이드 테스트";
    }

    function problems() internal override {
        problem(1, unicode"CounterV1 => CounterV2 로 업그레이드");
        problem(2, unicode"CounterV2 로 업그레이드 후 counter 값이 그대로인지 확인");
        problem(3, unicode"CounterV2 의 increment() 테스트");
        problem(4, unicode"CounterV2 의 reset() 테스트");
        problem(5, unicode"CounterV2 에서 컨트랙트 등록 없이 업그레이드 시도");
        problem(6, unicode"CounterV2 에서 Owner 가 아닌 주소가 컨트랙트 등록 시 실패");
        problem(7, unicode"CounterV2 에서 컨트랙트 등록 테스트");
        problem(8, unicode"CounterV2 에서 Owner 가 아닌 주소가 컨트랙트 등록 삭제 시 실패");
        problem(9, unicode"CounterV2 에서 컨트랙트 등록 삭제 테스트");
    }

    function _assess() internal override {
        changeAccountContext("PRIVATE_KEY_1");

        CounterV1 counterV1Impl = new CounterV1();
        CounterV2 counterV2Impl = new CounterV2();

        // CounterV1 구현체가 담긴 Proxy Contract 를 배포
        ERC1967Proxy proxy = new ERC1967Proxy(address(counterV1Impl), abi.encodePacked(INIT_METHOD_ID));
        ICounterV1 counterV1 = ICounterV1(address(proxy));

        // increment 함수를 호출하여 컨트랙트를 호출한다.
        counterV1.increment();

        // CounterV1 => CounterV2 로 업그레이드한다.
        (bool success,) =
            address(proxy).call(abi.encodeWithSignature("upgradeToAndCall(address,bytes)", address(counterV2Impl), ""));

        if (!succeed(1, success)) {
            return;
        }

        ICounterV2 counterV2 = ICounterV2(address(proxy));

        // 업그레이드를 해도, counter 값이 초기화가 되어서는 안된다.
        if (!succeed(2, counterV2.counter() == 1)) {
            return;
        }

        // CounterV2 의 increment 테스트
        counterV2.increment();

        if (!succeed(3, counterV2.counter() == 2)) {
            return;
        }

        // CounterV2 의 reset 테스트
        counterV2.reset();

        if (!succeed(4, counterV2.counter() == 0)) {
            return;
        }

        // 컨트랙트 등록 없이 업그레이드 시도
        (success,) =
            address(proxy).call(abi.encodeWithSignature("upgradeToAndCall(address,bytes)", address(counterV2Impl), ""));

        if (!succeed(5, !success)) {
            return;
        }

        // 다른 주소로 컨트랙트 등록
        changeAccountContext("PRIVATE_KEY_2");

        try counterV2.registerUpgradingContract(address(0x1)) {}
        catch {
            succeed(6, true);
        }

        changeAccountContext("PRIVATE_KEY_1");

        // 컨트랙트 등록
        counterV2.registerUpgradingContract(address(counterV2Impl));

        // 업그레이드 시도
        (success,) =
            address(proxy).call(abi.encodeWithSignature("upgradeToAndCall(address,bytes)", address(counterV2Impl), ""));

        if (!succeed(7, !success)) {
            return;
        }

        // 다른 주소로 등록 삭제
        counterV2.registerUpgradingContract(address(0x2));

        changeAccountContext("PRIVATE_KEY_2");

        try counterV2.revokeUpgradingContract(address(0x2)) {}
        catch {
            succeed(8, true);
        }

        changeAccountContext("PRIVATE_KEY_1");

        // 컨트랙트 등록 삭제
        counterV2.revokeUpgradingContract(address(counterV2Impl));

        succeed(9, true);
    }
}
