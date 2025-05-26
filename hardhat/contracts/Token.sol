// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SimpleToken
 * @dev A simple ERC20 token for testing purposes
 */
contract Token is ERC20, Ownable {
    uint8 private _decimals;
    
    /**
     * @dev Constructor that gives the msg.sender an initial supply of tokens
     */
    constructor() ERC20("TestToken", "TST") Ownable(msg.sender) {
        _decimals = 18;
        // Mint 1,000,000 tokens to the contract creator
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
    
    /**
     * @dev Returns the number of decimals used to get its user representation.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
    
    /**
     * @dev Mints `amount` tokens to the `recipient` address
     * Can only be called by the contract owner
     */
    function mint(address recipient, uint256 amount) public onlyOwner {
        _mint(recipient, amount);
    }
    
    /**
     * @dev Burns `amount` tokens from the caller's account
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}