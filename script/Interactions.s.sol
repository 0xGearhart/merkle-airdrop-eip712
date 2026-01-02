// SPDX-License-Identifier: MIT

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {CodeConstants, HelperConfig} from "./HelperConfig.s.sol";
import {DevOpsTools} from "@devops/DevOpsTools.sol";
import {Script} from "forge-std/Script.sol";

pragma solidity ^0.8.27;

contract ClaimAirdrop is Script, CodeConstants {
    MerkleAirdrop merkleAirdrop;
    HelperConfig helperConfig;
    HelperConfig.NetworkConfig config;
    uint8 v;
    bytes32 r;
    bytes32 s;

    function run() external {
        merkleAirdrop = MerkleAirdrop(DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid));
        helperConfig = new HelperConfig();
        config = helperConfig.getNetworkConfig();
        _claimAirdrop();
    }

    function _claimAirdrop() internal {
        _signMessage();
        vm.startBroadcast(config.account);
        merkleAirdrop.claim(config.account, AIRDROP_CLAIM_AMOUNT, config.merkleProof, v, r, s);
        vm.stopBroadcast();
    }

    function _signMessage() internal {
        // TODO: not sure if broadcast is needed for read operation
        // vm.startBroadcast();
        bytes32 digest = merkleAirdrop.getDigest(config.account, AIRDROP_CLAIM_AMOUNT);
        // vm.stopBroadcast();

        if (config.account == ANVIL_DEFAULT_ACCOUNT) {
            (v, r, s) = vm.sign(ANVIL_DEFAULT_KEY, digest);
        } else {
            // not sure how to trigger password input so encrypted keys can be used in scripts but i think this has something to do with it
            // vm.promptSecret("account keystore password: ");
            (v, r, s) = vm.sign(config.account, digest);
        }
    }
}

// hardcoded for example purposes, contract above is better for real deployments and interactions
// Swap out signature, claimingAddress, and merkleProof as needed.
// need to change saved signature based on what address and private key being used
contract ClaimAirdropWithUnsplitSignature is Script, CodeConstants {
    error ClaimAirdropWithUnsplitSignature__InvalidSignatureLength();

    MerkleAirdrop merkleAirdrop;

    // hardcoded address to go with signature
    address claimingAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    // hardcoded merkleProof to go with signature
    bytes32[] merkleProof = [
        bytes32(0x0c7ef881bb675a5858617babe0eb12b538067e289d35d5b044ee76b79d335191),
        bytes32(0x04a0dd9684f371cb72c8dbe0c219550e1ce8c81b96d9cc582d4a3631e1d06172),
        bytes32(0x2aadccb0553b8c9968b78ca32bb891c1dd527eb553ff5b19aa35560e4757e5b0)
    ];
    // signed digest for claimingAddress.
    bytes private signature =
        hex"64d5e372635d7fc8dcee5557a4816f135b1d004a37c3126725edde253f9bddb3730156c30fb42695c5819f04d6094d2873df8926aba36facfc4d54aa21d5f1dd1c";

    function run() external {
        merkleAirdrop = MerkleAirdrop(DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid));
        _claimAirdrop();
    }

    function _claimAirdrop() internal {
        (uint8 v, bytes32 r, bytes32 s) = _splitSignature(signature);
        vm.startBroadcast(claimingAddress);
        merkleAirdrop.claim(claimingAddress, AIRDROP_CLAIM_AMOUNT, merkleProof, v, r, s);
        vm.stopBroadcast();
    }

    // when using "cast sign" in terminal the signature is given as a bytes packed object and needs to be split manually for the current implementation of merkle airdrop that takes v, r, and s separately
    // Openzeppelin library has ECDSA.tryRecover option that takes whole bytes signature and does the split for you before verification but current merkle airdrop takes v, r, and s separately. Easy to switch out depending on desired input.
    // this is mostly for example purposes or if you must use cast sign
    function _splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert ClaimAirdropWithUnsplitSignature__InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
