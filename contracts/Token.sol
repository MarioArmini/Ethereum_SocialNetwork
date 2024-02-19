// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Pausable, Ownable(msg.sender) {

  string private _name;

  string private _symbol;

  uint8 private _decimals;

  constructor(string memory name, string memory symbol, uint8 decimals) ERC20(name, symbol) {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;

    _transferOwnership(_msgSender());
  }

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    _unpause();
  }

  function mint(address to, uint256 amount) external onlyOwner {
    _mint(to, amount);
  }

  function burn(uint256 amount) external {
    _burn(_msgSender(), amount);
  }

  function transfer(address recipient, uint256 amount) public override whenNotPaused returns (bool) {
    return super.transfer(recipient, amount);
  }

  function transferFrom(address sender, address recipient, uint256 amount) public override whenNotPaused returns (bool) {
    return super.transferFrom(sender, recipient, amount);
  }

  function approve(address spender, uint256 amount) public override whenNotPaused returns (bool) {
    return super.approve(spender, amount);
  }

  function name() public view override returns (string memory) {
    return _name;
  }

  function symbol() public view override returns (string memory) {
    return _symbol;
  }

  function decimals() public view override returns (uint8) {
    return _decimals;
  }

}