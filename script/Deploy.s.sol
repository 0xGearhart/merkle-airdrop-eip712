// SPDX-License-Identifier: MIT

import {AirdropToken} from "../src/AirdropToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {CodeConstants, HelperConfig} from "./HelperConfig.s.sol";
import {MerkleBuilder} from "./MerkleBuilder.s.sol";
import {Script} from "forge-std/Script.sol";

pragma solidity ^0.8.27;

contract Deploy is Script, CodeConstants {
    function run() external returns (AirdropToken airdropToken, MerkleAirdrop merkleAirdrop) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getNetworkConfig();

        vm.startBroadcast(config.account);
        airdropToken = new AirdropToken(TOKEN_NAME, TOKEN_SYMBOL, INITIAL_SUPPLY);
        merkleAirdrop =
            new MerkleAirdrop(address(airdropToken), config.merkleRoot, EIP712_DAPP_NAME, EIP712_DAPP_VERSION);
        bool success = airdropToken.transfer(address(merkleAirdrop), INITIAL_SUPPLY);
        success;
        vm.stopBroadcast();
    }
}
