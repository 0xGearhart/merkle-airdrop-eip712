// SPDX-License-Identifier: MIT

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

pragma solidity ^0.8.27;

/**
 * @title MerkleAirdrop
 * @author Gearhart
 * @notice Airdrop claim contract that uses a merkle tree to minimize gas expenditure
 */
contract MerkleAirdrop is EIP712 {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error MerkleAirdrop__InvalidMerkleProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/
    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");
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
    constructor(
        address airdropToken,
        bytes32 merkleRoot,
        string memory dappName,
        string memory dappVersion
    )
        EIP712(dappName, dappVersion)
    {
        i_airdropToken = IERC20(airdropToken);
        i_merkleRoot = merkleRoot;
    }

    /**
     * @notice Claim airdrop for an address
     * @param account address of account claiming tokens
     * @param amount amount of tokens to be claimed
     * @param merkleProof merkle proof to verify account is eligible to claim
     * @param v uint8 v component of signature
     * @param r bytes32 r component of signature
     * @param s bytes32 s component of signature
     */
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        // make sure account has not already claimed
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        // verify signature
        if (!_isValidSignature(account, getDigest(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }
        // generate leaf
        // this method is very gas inefficient. Using assembly or EfficientHashLib from Solady is suggested for production.
        // will leave as is for verbosity and demonstration purposes
        bytes32 merkleLeaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        // verify merkle proof
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, merkleLeaf)) {
            revert MerkleAirdrop__InvalidMerkleProof();
        }
        // update has claimed mapping
        s_hasClaimed[account] = true;
        // emit and transfer tokens
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    function _isValidSignature(
        address account,
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Get bytes32 digest in EIP712 format for signature verification
     * @param account address of account to claim
     * @param amount amount of tokens to be claimed
     */
    function getDigest(address account, uint256 amount) public view returns (bytes32 digest) {
        digest =
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    /**
     * @notice Get claim status for a specific account
     * @param account address of account to get claim status for
     */
    function getClaimStatus(address account) external view returns (bool) {
        return s_hasClaimed[account];
    }

    /**
     * @notice Get Airdrop Token address
     */
    function getAirdropToken() external view returns (address) {
        return address(i_airdropToken);
    }

    /**
     * @notice Get stored Merkle root
     */
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }
}
