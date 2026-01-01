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
    uint256 constant BASE_MAINNET_CHAIN_ID = 8453;
    uint256 constant BASE_SEPOLIA_CHAIN_ID = 84_532;

    // merkle airdrop contract info
    string constant EIP712_DAPP_NAME = "MerkleAirdrop";
    string constant EIP712_DAPP_VERSION = "v1.0";
    uint256 constant AIRDROP_CLAIM_AMOUNT = 25 ether;
    bytes32 constant LOCAL_MERKLE_ROOT = 0xaa2b3d9448522a0dd0d6ffaa3d8da42e48dee685aa98d4484d774a14fc48a74f;
    bytes32 constant MERKLE_ROOT = 0x947c42541535f83c00b2fa82c52c26e6399392856adc342af2b559346b48fa8b;
    bytes32[] LOCAL_MERKLE_PROOF = [
        bytes32(0x0c7ef881bb675a5858617babe0eb12b538067e289d35d5b044ee76b79d335191),
        bytes32(0x04a0dd9684f371cb72c8dbe0c219550e1ce8c81b96d9cc582d4a3631e1d06172),
        bytes32(0x2aadccb0553b8c9968b78ca32bb891c1dd527eb553ff5b19aa35560e4757e5b0)
    ];
    bytes32[] MERKLE_PROOF = [
        bytes32(0xe6ee55273b67b99988e64ab56db4de62eb12f7c730f92f924530c6123c1e90b3),
        bytes32(0xf4216065bf6ac971b2f1ba0fef5920345dcaeceabf5f200030a1cd530dd44a89),
        bytes32(0x2aadccb0553b8c9968b78ca32bb891c1dd527eb553ff5b19aa35560e4757e5b0)
    ];
}

contract HelperConfig is Script, CodeConstants {
    error HelperConfig__InvalidNetwork(uint256 chainId);

    struct NetworkConfig {
        address account;
        bytes32 merkleRoot;
        bytes32[] merkleProof;
    }

    mapping(uint256 chainid => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[LOCAL_CHAIN_ID] = _getLocalConfig();
        networkConfigs[ETH_MAINNET_CHAIN_ID] = _getEthMainnetConfig();
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = _getEthSepoliaConfig();
        networkConfigs[ARB_MAINNET_CHAIN_ID] = _getArbMainnetConfig();
        networkConfigs[ARB_SEPOLIA_CHAIN_ID] = _getArbSepoliaConfig();
        networkConfigs[BASE_MAINNET_CHAIN_ID] = _getBaseMainnetConfig();
        networkConfigs[BASE_SEPOLIA_CHAIN_ID] = _getBaseSepoliaConfig();
    }

    function getNetworkConfig() public view returns (NetworkConfig memory) {
        if (networkConfigs[block.chainid].account != address(0)) {
            return networkConfigs[block.chainid];
        } else {
            revert HelperConfig__InvalidNetwork(block.chainid);
        }
    }

    function _getEthMainnetConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            account: vm.envAddress("DEFAULT_KEY_ADDRESS"), merkleRoot: MERKLE_ROOT, merkleProof: MERKLE_PROOF
        });
    }

    function _getEthSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            account: vm.envAddress("DEFAULT_KEY_ADDRESS"), merkleRoot: MERKLE_ROOT, merkleProof: MERKLE_PROOF
        });
    }

    function _getArbMainnetConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            account: vm.envAddress("DEFAULT_KEY_ADDRESS"), merkleRoot: MERKLE_ROOT, merkleProof: MERKLE_PROOF
        });
    }

    function _getArbSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            account: vm.envAddress("DEFAULT_KEY_ADDRESS"), merkleRoot: MERKLE_ROOT, merkleProof: MERKLE_PROOF
        });
    }

    function _getBaseMainnetConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            account: vm.envAddress("DEFAULT_KEY_ADDRESS"), merkleRoot: MERKLE_ROOT, merkleProof: MERKLE_PROOF
        });
    }

    function _getBaseSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            account: vm.envAddress("DEFAULT_KEY_ADDRESS"), merkleRoot: MERKLE_ROOT, merkleProof: MERKLE_PROOF
        });
    }

    function _getLocalConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                account: ANVIL_DEFAULT_ACCOUNT, merkleRoot: LOCAL_MERKLE_ROOT, merkleProof: LOCAL_MERKLE_PROOF
            });
    }
}
