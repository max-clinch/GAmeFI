// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// contract address = 0x58482F7C4297DA5A1e7dC133633e776cF794acDB
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract  LpeToken is ERC20, ERC20Burnable, ERC20Pausable, Ownable {
    constructor() ERC20("MiliCoin", "MC") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10**decimals());
    }
    function _update(address from, address to, uint256 value) internal virtual override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }
}