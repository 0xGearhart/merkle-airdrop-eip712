// SPDX-License-Identifier: MIT

import {Deploy} from "../../script/Deploy.s.sol";
import {CodeConstants, HelperConfig} from "../../script/HelperConfig.s.sol";
import {AirdropToken} from "../../src/AirdropToken.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {Test} from "forge-std/Test.sol";

pragma solidity ^0.8.27;

contract DeployTest is Test, CodeConstants {
    Deploy deploy;
    MerkleAirdrop merkleAirdrop;
    AirdropToken airdropToken;
    HelperConfig helperConfig;
    HelperConfig.NetworkConfig config;

    function setUp() public {
        helperConfig = new HelperConfig();
        config = helperConfig.getNetworkConfig();
        deploy = new Deploy();
        (airdropToken, merkleAirdrop) = deploy.run();
    }

    function testAirdropTokenWasDeployedCorrectly() public view {
        assertEq(airdropToken.name(), TOKEN_NAME);
        assertEq(airdropToken.symbol(), TOKEN_SYMBOL);
        assertEq(airdropToken.totalSupply(), INITIAL_SUPPLY);
    }

    function testMerkleAirdropHasInitialSupplyAndDeployerHasZero() public view {
        assertEq(airdropToken.balanceOf(config.account), 0);
        assertEq(airdropToken.balanceOf(address(merkleAirdrop)), INITIAL_SUPPLY);
    }

    function testMerkleRootWasSetCorrectly() public view {
        assertEq(merkleAirdrop.getMerkleRoot(), LOCAL_MERKLE_ROOT);
    }

    function testAirdropTokenAddressWasSetCorrectly() public view {
        assertEq(merkleAirdrop.getAirdropToken(), address(airdropToken));
    }
}
