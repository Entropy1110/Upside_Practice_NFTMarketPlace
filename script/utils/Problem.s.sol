pragma solidity ^0.8.20;

import {Vm} from "forge-std/Vm.sol";
import {Script, console} from "forge-std/Script.sol";
import {console, StdStyle} from "forge-std/Script.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

abstract contract Problem {
    bool finished = false;
    string[] subProblems;
    bool[] success;
    Vm vm;

    constructor(Vm vm_) {
        vm = vm_;
    }

    function description() public pure virtual returns (string memory) {
        return "";
    }

    function problems() internal virtual {}

    function problem(uint256 id, string memory desc) internal {
        require(subProblems.length + 1 == id);
        subProblems.push(desc);
        success.push(false);
    }

    function succeed(uint256 idx, bool required) internal returns (bool) {
        success[idx - 1] = required;
        return required;
    }

    function assess() external {
        require(!finished);
        finish();
        _assess();
    }

    function _assess() internal virtual {}

    function printResult() external {
        if (!finished) {
            finish();
        }

        for (uint256 i = 0; i < subProblems.length; ++i) {
            console.log(passOrFail(success[i]), problemPrefix(i), problemDescription(i));
        }
    }

    function finish() internal {
        problems();
        finished = true;
    }

    function problemPrefix(uint256 i) private pure returns (string memory) {
        return StdStyle.bold(StdStyle.blue(string.concat("Problem #", Strings.toString(i + 1))));
    }

    function problemDescription(uint256 i) private view returns (string memory) {
        return StdStyle.underline(StdStyle.blue(subProblems[i]));
    }

    function passOrFail(bool pass) private pure returns (string memory) {
        return pass ? unicode"✅" : unicode"❌";
    }

    function changeAccountContext(string memory envKey) internal {
        vm.stopBroadcast();
        uint256 deployerPrivateKey = vm.envUint(envKey);
        vm.startBroadcast(deployerPrivateKey);
    }
}
