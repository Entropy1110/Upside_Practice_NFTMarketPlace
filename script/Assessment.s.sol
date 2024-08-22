pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {CounterV1} from "../src/01_upgradeable/CounterV1.sol";
import {CounterV2} from "../src/01_upgradeable/CounterV2.sol";
import {ICounterV1} from "../src/01_upgradeable/ICounterV1.sol";
import {Problem} from "./utils/Problem.s.sol";
import {UpgradeableProblem} from "./problems/UpgradeableProblem.s.sol";
import {EIP712Problem} from "./problems/EIP712Problem.s.sol";
import {MarketPlaceProblem} from "./problems/MarketPlaceProblem.s.sol";

contract Assessment is Script {
    Problem[] problems;

    function setUp() public {
        __init_problems();
    }

    function run() external {
        vm.startBroadcast();

        for (uint256 i = 0; i < problems.length; ++i) {
            console.log(problems[i].description());

            try problems[i].assess() {} catch {}
            problems[i].printResult();
            console.log("");
        }
    }

    function __init_problems() internal {
        problems.push(new UpgradeableProblem(vm));
        problems.push(new EIP712Problem(vm));
        problems.push(new MarketPlaceProblem(vm));
    }
}
