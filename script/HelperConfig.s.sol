// SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";

pragma solidity ^0.8.27;

contract CodeConstants {
    // airdrop token contract info
    string constant TOKEN_NAME = "AirdropToken";
    string constant TOKEN_SYMBOL = "AIR";
    uint256 constant INITIAL_SUPPLY = 100_000 ether;

    // default local account and key for signing
    address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 constant ANVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    // chain ids
    uint256 constant LOCAL_CHAIN_ID = 31_337;
    uint256 constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11_155_111;
    uint256 constant ARB_MAINNET_CHAIN_ID = 42_161;
    uint256 constant ARB_SEPOLIA_CHAIN_ID = 421_614;

    // merkle airdrop contract info
    bytes32 constant LOCAL_MERKLE_ROOT = 0xaa2b3d9448522a0dd0d6ffaa3d8da42e48dee685aa98d4484d774a14fc48a74f;
    bytes32 constant MERKLE_ROOT = 0x947c42541535f83c00b2fa82c52c26e6399392856adc342af2b559346b48fa8b;
    uint256 constant AIRDROP_CLAIM_AMOUNT = 25 ether;
    string constant EIP712_DAPP_NAME = "MerkleAirdrop";
    string constant EIP712_DAPP_VERSION = "v1.0";
}

contract HelperConfig is Script, CodeConstants {
    error HelperConfig__InvalidNetwork(uint256 chainId);

    struct NetworkConfig {
        address account;
        bytes32 merkleRoot;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainid => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[ETH_MAINNET_CHAIN_ID] = _getEthMainnetConfig();
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = _getEthSepoliaConfig();
        networkConfigs[ARB_MAINNET_CHAIN_ID] = _getArbMainnetConfig();
        networkConfigs[ARB_SEPOLIA_CHAIN_ID] = _getArbSepoliaConfig();
    }

    function getNetworkConfig() public returns (NetworkConfig memory) {
        if (block.chainid == LOCAL_CHAIN_ID) {
            return _getOrCreateLocalConfig();
        } else if (networkConfigs[block.chainid].account != address(0)) {
            return networkConfigs[block.chainid];
        } else {
            revert HelperConfig__InvalidNetwork(block.chainid);
        }
    }

    function _getEthMainnetConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({account: vm.envAddress("DEFAULT_KEY_ADDRESS"), merkleRoot: MERKLE_ROOT});
    }

    function _getEthSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({account: vm.envAddress("DEFAULT_KEY_ADDRESS"), merkleRoot: MERKLE_ROOT});
    }

    function _getArbMainnetConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({account: vm.envAddress("DEFAULT_KEY_ADDRESS"), merkleRoot: MERKLE_ROOT});
    }

    function _getArbSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({account: vm.envAddress("DEFAULT_KEY_ADDRESS"), merkleRoot: MERKLE_ROOT});
    }

    function _getOrCreateLocalConfig() public returns (NetworkConfig memory) {
        // if mocks are already deployed, return struct
        if (localNetworkConfig.account != address(0)) {
            return localNetworkConfig;
        }
        // // otherwise, deploy mocks and save struct
        // console2.log("Deploying mocks...");
        // vm.startBroadcast(ANVIL_DEFAULT_ACCOUNT);
        // vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({account: ANVIL_DEFAULT_ACCOUNT, merkleRoot: LOCAL_MERKLE_ROOT});

        return localNetworkConfig;
    }
}
