// SPDX-License-Identifier: MIT

import {Deploy} from "../../script/Deploy.s.sol";
import {CodeConstants, HelperConfig} from "../../script/HelperConfig.s.sol";
import {ClaimAirdrop} from "../../script/interactions.s.sol";
import {ClaimAirdropWithUnsplitSignature} from "../../script/interactions.s.sol";
import {AirdropToken} from "../../src/AirdropToken.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {DevOpsTools} from "@devops/DevOpsTools.sol";
import {Test} from "forge-std/Test.sol";

pragma solidity 0.8.33;

contract InteractionsTest is Test, CodeConstants {
    Deploy deploy;
    MerkleAirdrop merkleAirdrop;
    AirdropToken airdropToken;
    HelperConfig helperConfig;
    HelperConfig.NetworkConfig config;
    ClaimAirdrop claimAirdrop;
    ClaimAirdropWithUnsplitSignature claimAirdropWithUnsplitSignature;

    function testClaimAirdropScriptLocally() public {
        // deploy contracts on selected chain
        helperConfig = new HelperConfig();
        config = helperConfig.getNetworkConfig();
        deploy = new Deploy();
        (airdropToken, merkleAirdrop) = deploy.run();
        claimAirdrop = new ClaimAirdrop();

        // verify initial state
        assertEq(merkleAirdrop.getClaimStatus(config.account), false);
        assertEq(airdropToken.balanceOf(config.account), 0);
        assertEq(airdropToken.balanceOf(address(merkleAirdrop)), INITIAL_SUPPLY);

        // run script
        claimAirdrop.run();

        // verify result
        assertEq(merkleAirdrop.getClaimStatus(config.account), true);
        assertEq(airdropToken.balanceOf(config.account), AIRDROP_CLAIM_AMOUNT);
        assertEq(airdropToken.balanceOf(address(merkleAirdrop)), INITIAL_SUPPLY - AIRDROP_CLAIM_AMOUNT);
    }

    function testClaimAirdropWithUnsplitSignatureScriptLocally() public {
        // deploy contracts on selected chain
        helperConfig = new HelperConfig();
        config = helperConfig.getNetworkConfig();
        deploy = new Deploy();
        (airdropToken, merkleAirdrop) = deploy.run();
        claimAirdropWithUnsplitSignature = new ClaimAirdropWithUnsplitSignature();

        // verify initial state
        assertEq(merkleAirdrop.getClaimStatus(config.account), false);
        assertEq(airdropToken.balanceOf(config.account), 0);
        assertEq(airdropToken.balanceOf(address(merkleAirdrop)), INITIAL_SUPPLY);

        // run script
        claimAirdropWithUnsplitSignature.run();

        // verify result
        assertEq(merkleAirdrop.getClaimStatus(config.account), true);
        assertEq(airdropToken.balanceOf(config.account), AIRDROP_CLAIM_AMOUNT);
        assertEq(airdropToken.balanceOf(address(merkleAirdrop)), INITIAL_SUPPLY - AIRDROP_CLAIM_AMOUNT);
    }
}
