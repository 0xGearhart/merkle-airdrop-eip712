// SPDX-License-Identifier: MIT

import {Deploy} from "../../script/Deploy.s.sol";
import {CodeConstants, HelperConfig} from "../../script/HelperConfig.s.sol";
import {AirdropToken} from "../../src/AirdropToken.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {Test} from "forge-std/Test.sol";

pragma solidity 0.8.33;

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

    function testAirdropTokenAddressWasSetCorrectly() public view {
        assertEq(merkleAirdrop.getAirdropToken(), address(airdropToken));
    }

    function testMerkleRootWasSetCorrectlyOnLocalChain() public view {
        assertEq(config.account, ANVIL_DEFAULT_ACCOUNT);
        assertEq(config.merkleRoot, LOCAL_MERKLE_ROOT);
        assertEq(config.merkleProof, LOCAL_MERKLE_PROOF);

        assertEq(merkleAirdrop.getMerkleRoot(), LOCAL_MERKLE_ROOT);
    }

    function testMerkleRootWasSetCorrectly() public {
        // get rpc url from .env
        string memory arbSepoliaRpcUrl = vm.envString("ARB_SEPOLIA_RPC_URL");
        // create and switch to forked blockchain
        vm.createSelectFork(arbSepoliaRpcUrl);
        // deploy on forked chain
        helperConfig = new HelperConfig();
        config = helperConfig.getNetworkConfig();
        deploy = new Deploy();
        (airdropToken, merkleAirdrop) = deploy.run();
        // verify merkle root
        assertEq(config.account, vm.envAddress("DEFAULT_KEY_ADDRESS"));
        assertEq(config.merkleRoot, MERKLE_ROOT);
        assertEq(config.merkleProof, MERKLE_PROOF);
        assertEq(merkleAirdrop.getMerkleRoot(), MERKLE_ROOT);
    }
}
