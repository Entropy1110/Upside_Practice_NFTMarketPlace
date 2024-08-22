pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
    constructor() ERC20("Upside Token", "UPS") {}

    function mintTo(address addr, uint256 amount) external {
        _mint(addr, amount);
    }
}
