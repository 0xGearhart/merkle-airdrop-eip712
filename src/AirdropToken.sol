// SPDX-License-Identifier: MIT

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

pragma solidity ^0.8.27;

/**
 * @title AirdropToken
 * @author Dustin Gearhart
 * @notice Token to be claimed from MerkleAirdrop
 */
contract AirdropToken is ERC20 {
    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) ERC20(_name, _symbol) {
        _mint(msg.sender, _initialSupply);
    }
}
