// SPDX-License-Identifier: MIT

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

pragma solidity ^0.8.27;

/**
 * @title MerkleAirdrop
 * @author Dustin Gearhart
 * @notice Airdrop claim contract that uses a merkle tree to minimize gas expenditure
 */
contract MerkleAirdrop {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error MerkleAirdrop__InvalidMerkleProof();
    error MerkleAirdrop__AlreadyClaimed();

    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/
    IERC20 private immutable i_airdropToken;
    bytes32 private immutable i_merkleRoot;
    mapping(address claimer => bool) private s_hasClaimed;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Claim(address indexed account, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor(address airdropToken, bytes32 merkleRoot) {
        i_airdropToken = IERC20(airdropToken);
        i_merkleRoot = merkleRoot;
    }

    /**
     * @notice Claim airdrop for an address
     * @param account address of account claiming tokens
     * @param amount amount of tokens to be claimed
     * @param merkleProof merkle proof to verify account is eligible to claim
     */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        // generate leaf
        bytes32 merkleLeaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        // verify merkle proof
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, merkleLeaf)) {
            revert MerkleAirdrop__InvalidMerkleProof();
        }
        // make sure account has not already claimed
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        // update has claimed mapping
        s_hasClaimed[account] = true;
        // emit and transfer tokens
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Get Airdrop Token address
     */
    function getAirdropToken() external view returns (address) {
        return address(i_airdropToken);
    }

    /**
     * @notice Get claim status for a specific account
     * @param account address of account to get claim status for
     */
    function getClaimStatus(address account) external view returns (bool) {
        return s_hasClaimed[account];
    }

    /**
     * @notice Get stored Merkle root
     */
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }
}
