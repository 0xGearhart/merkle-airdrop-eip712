// SPDX-License-Identifier: MIT

import {Script, console2} from "forge-std/Script.sol";

pragma solidity ^0.8.27;

contract CodeConstants {
    string constant TOKEN_NAME = "AirdropToken";
    string constant TOKEN_SYMBOL = "AIR";
    uint256 constant INITIAL_SUPPLY = 100_000 ether;

    address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 constant ANVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    uint256 constant LOCAL_CHAINID = 31_337;
    uint256 constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11_155_111;
    uint256 constant ARB_MAINNET_CHAIN_ID = 42_161;
    uint256 constant ARB_SEPOLIA_CHAIN_ID = 421_614;

    bytes32 constant LOCAL_MERKLE_ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
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
        if (block.chainid == LOCAL_CHAINID) {
            return _getOrCreateLocalConfig();
        } else if (networkConfigs[block.chainid].account != address(0)) {
            return networkConfigs[block.chainid];
        } else {
            revert HelperConfig__InvalidNetwork(block.chainid);
        }
    }

    function _getEthMainnetConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({account: vm.envAddress("DEFAULT_KEY_ADDRESS"), merkleRoot: LOCAL_MERKLE_ROOT});
    }

    function _getEthSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({account: vm.envAddress("DEFAULT_KEY_ADDRESS"), merkleRoot: LOCAL_MERKLE_ROOT});
    }

    function _getArbMainnetConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({account: vm.envAddress("DEFAULT_KEY_ADDRESS"), merkleRoot: LOCAL_MERKLE_ROOT});
    }

    function _getArbSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({account: vm.envAddress("DEFAULT_KEY_ADDRESS"), merkleRoot: LOCAL_MERKLE_ROOT});
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
