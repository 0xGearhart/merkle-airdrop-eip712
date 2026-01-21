# Merkle Airdrop with EIP-712 Signatures

**⚠️ This project is not audited, use at your own risk**

## Table of Contents

- [Merkle Airdrop with EIP-712 Signatures](#merkle-airdrop-with-eip-712-signatures)
  - [Table of Contents](#table-of-contents)
  - [About](#about)
    - [Key Features](#key-features)
    - [Architecture](#architecture)
  - [Getting Started](#getting-started)
    - [Requirements](#requirements)
    - [Quickstart](#quickstart)
    - [Environment Setup](#environment-setup)
  - [Usage](#usage)
    - [Build](#build)
    - [Testing](#testing)
    - [Test Coverage](#test-coverage)
    - [Deploy Locally](#deploy-locally)
    - [Interact with Contract](#interact-with-contract)
  - [Deployment](#deployment)
    - [Deploy to Testnet](#deploy-to-testnet)
    - [Verify Contract](#verify-contract)
    - [Deployment Addresses](#deployment-addresses)
  - [Security](#security)
    - [Audit Status](#audit-status)
    - [Access Control (Roles \& Permissions)](#access-control-roles--permissions)
    - [Known Limitations](#known-limitations)
  - [Gas Optimization](#gas-optimization)
  - [Contributing](#contributing)
  - [License](#license)

## About

A gas-efficient airdrop distribution system using Merkle trees to verify claim eligibility and EIP-712 typed signatures for secure claim authorization. This implementation allows users to claim pre-allocated airdrop tokens with minimal on-chain verification overhead.

### Key Features

- **Merkle Tree Verification**: Gas-efficient eligibility verification using Merkle proofs
- **EIP-712 Signatures**: Typed signature scheme for secure claim authorization
- **Immutable Token Contract**: Secure ERC20 token for airdrop distribution
- **Claim Tracking**: Prevents duplicate claims with one-time claim verification per address
- **Multi-network Support**: Deployable on Ethereum, Arbitrum, and Base networks

**Tech Stack:**
- Solidity 0.8.33
- Foundry (Forge for building and testing)
  - forge-std version (v1.11.0)
- OpenZeppelin Contracts (ERC20, EIP-712, Merkle proof utilities, ECDSA signature recovery)
  - openzeppelin-contracts version (v5.5.0)
- Murky (Merkle tree generation for testing)
  - murky version (v0.1.0)

### Architecture

```
┌──────────────────────────────────────────────────────────┐
│                  Whitelisted Users/EOAs                  │
└──────────┬─────────────────────────────┬─────────────────┘
           │                             │
           │ Direct claim                │ Authorize signature
           │ with signature              │ (delegate claim)
           │                             ▼
           │                    ┌──────────────────────────┐
           │                    │  Authorized Claimer      │
           │                    │  (Non-whitelisted EOA)   │
           │                    └────────┬─────────────────┘
           │                             │
           │ claim(address,              │ claim(address,
           │ amount, proof,              │ amount, proof,
           │ v, r, s)                    │ v, r, s)
           │                             │
           └─────────────┬───────────────┘
                         ▼
         ┌──────────────────────────────────────────┐
         │                                          │
         │         MerkleAirdrop Contract           │
         │                                          │
         │ ┌──────────────────┐  ┌────────────────┐ │
         │ │  Merkle Root     │  │ EIP-712 Domain │ │
         │ │  (Eligibility)   │  │(Signature Ver) │ │
         │ └──────────────────┘  └────────────────┘ │
         │                                          │
         │ ┌────────────────────────────────────┐   │
         │ │ Claim Status Tracking (per address)│   │
         │ │(Prevents duplicate claims)         │   │
         │ └────────────────────────────────────┘   │
         │                                          │
         └───────────────┬──────────────────────────┘
                         │ safeTransfer()
                         │
                         ▼
            ┌─────────────────────────┐
            │  AirdropToken (ERC20)   │
            │  Token Distribution     │
            └─────────────────────────┘
```

**Repository Structure:**
```
merkle-airdrop-eip712/
├── src/
│   ├── AirdropToken.sol              # ERC20 token for airdrop
│   └── MerkleAirdrop.sol             # Core airdrop claim contract with EIP-712
├── script/
│   ├── Deploy.s.sol                  # Deployment script
│   ├── Interactions.s.sol            # Claim interaction scripts
│   ├── GenerateInput.s.sol           # Generate merkle tree input data
│   ├── MerkleBuilder.s.sol           # Build merkle tree from input
│   ├── HelperConfig.s.sol            # Network configuration
│   ├── SplitSignature.s.sol          # Split full signature into v,r,s
│   └── target/                       # Generated merkle tree outputs
├── test/
│   ├── unit/
│   │   └── MerkleBuilderTest.t.sol   # Merkle tree generation tests
│   └── integration/
│       ├── DeployTest.t.sol          # Deployment tests
│       ├── MerkleAirdropTest.t.sol   # Airdrop claim functionality tests
│       └── InteractionsTest.t.sol    # Full integration tests
├── lib/                               # Dependencies
├── foundry.toml                       # Foundry configuration
├── Makefile                           # Convenient make targets
└── README.md                          # This file
```

## Getting Started

### Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - Verify installation: `git --version`
- [foundry](https://getfoundry.sh/)
  - Verify installation: `forge --version`

### Quickstart

```bash
git clone https://github.com/0xGearhart/merkle-airdrop-eip712
cd merkle-airdrop-eip712
make
```

### Environment Setup

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Configure your `.env` file:**
   ```bash
   ETH_SEPOLIA_RPC_URL=your_sepolia_rpc_url_here
   ETH_MAINNET_RPC_URL=your_mainnet_rpc_url_here
   ARB_SEPOLIA_RPC_URL=your_arbitrum_sepolia_rpc_url_here
   ARB_MAINNET_RPC_URL=your_arbitrum_mainnet_rpc_url_here
   BASE_SEPOLIA_RPC_URL=your_base_sepolia_rpc_url_here
   BASE_MAINNET_RPC_URL=your_base_mainnet_rpc_url_here
   ETHERSCAN_API_KEY=your_etherscan_api_key_here
   DEFAULT_KEY_ADDRESS=public_address_of_your_encrypted_private_key_here
   SECONDARY_ADDRESS=secondary_address_for_whitelisting
   ```

3. **Get testnet ETH:**
   - Ethereum Sepolia: [cloud.google.com/application/web3/faucet/ethereum/sepolia](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)
   - Base Sepolia & Arbitrum Sepolia (requires mainnet Chainlink balance): [faucets.chain.link](https://faucets.chain.link/)

4. **Configure Makefile**
   - Change account name in Makefile to the name of your desired encrypted key
   - Change `--account defaultKey` to `--account <YOUR_ENCRYPTED_KEY_NAME>`
   - Check encrypted key names stored locally with:

   ```bash
   cast wallet list
   ```
   
   - **If no encrypted keys found**, encrypt private key to be used securely within foundry:

   ```bash
   cast wallet import <account_name> --interactive
   ```

**⚠️ Security Warning:**
- Never commit your `.env` file
- Never use your mainnet private key for testing
- Use a separate wallet with only testnet funds

## Usage

### Build

Compile the contracts:

```bash
forge build
```

### Testing

Run the test suite:

```bash
forge test
```

Run tests with verbosity:

```bash
forge test -vvv
```

Run specific test:

```bash
forge test --mt testFunctionName
```

### Test Coverage

Generate coverage report:

```bash
forge coverage
```

Create test coverage report and save to .txt file:

```bash
make coverage-report
```

### Deploy Locally

Start a local Anvil node:

```bash
make anvil
```

Deploy to local node (in another terminal):

```bash
make deploy
```

### Interact with Contract

**Generate Merkle Tree:**
Build the merkle tree from input data and generate the root:

```bash
make merkle
```

**Get Claim Digest:**
Get the EIP-712 typed hash digest for signing:

```bash
make get-digest
```

**Sign Digest:**
Sign the digest with your private key:

```bash
make sign-digest
```

**Claim Airdrop (Streamlined):**
Automatically create digest, sign, and claim in one script:

```bash
make claim-airdrop
```

**Claim with Full Signature:**
Use a pre-generated full signature (requires splitting first):

```bash
make claim-airdrop-with-full-sig
```

**Split Full Signature:**
Split a full signature into v, r, and s components:

```bash
make split-signature
```

## Deployment

### Deploy to Testnet

Deploy to Sepolia:

```bash
make deploy ARGS="--network eth sepolia"
```

Deploy to Arbitrum Sepolia:

```bash
make deploy ARGS="--network arb sepolia"
```

Deploy to Base Sepolia:

```bash
make deploy ARGS="--network base sepolia"
```

Or using forge directly:

```bash
forge script script/Deploy.s.sol:Deploy --rpc-url $ETH_SEPOLIA_RPC_URL --account defaultKey --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
```

### Verify Contract

If automatic verification fails:

```bash
forge verify-contract <CONTRACT_ADDRESS> src/MerkleAirdrop.sol:MerkleAirdrop --chain-id 11155111 --etherscan-api-key $ETHERSCAN_API_KEY
```

### Deployment Addresses

| Network          | MerkleAirdrop Address                        | AirdropToken Address                         | Block                                                                                              |
| ---------------- | -------------------------------------------- | -------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| Arbitrum Sepolia | `0x0292d5E5A58a1BE1603a6fAb2D893eb1b6039D6F` | `0x04CD94DE2733Bff4A359c3D595573F479430cac9` | [View on Arbiscan](https://sepolia.arbiscan.io/address/0x0292d5E5A58a1BE1603a6fAb2D893eb1b6039D6F) |

## Security

### Audit Status

⚠️ **This contract has not been audited.** Use at your own risk.

For production use, consider:
- Professional security audit
- Bug bounty program
- Gradual rollout with monitoring

### Access Control (Roles & Permissions)

This protocol does **not** implement role-based access control through OpenZeppelin's `AccessControl`. The contracts follow a **stateless, permissionless design**:

**MerkleAirdrop Contract:**
- **No Owner**: The contract is deployed without an owner. Once deployed, it operates autonomously with no administrative functions.
- **Permissionless Claims**: Any address with a valid Merkle proof and corresponding EIP-712 signature can claim their airdrop.
- **One-Time Claims Per Address**: Uses `s_hasClaimed` mapping to prevent duplicate claims, but does not restrict who can call the function.

**AirdropToken Contract:**
- **Initial Minter**: The deployer of the contract receives the initial token supply upon deployment.
- **Standard ERC20**: No special roles; functions follow standard ERC20 behavior (transfer, approve, etc.).
- **Tokens Transferred to MerkleAirdrop**: All airdrop tokens are transferred to the `MerkleAirdrop` contract during deployment for distribution.

**Key Security Properties:**
- ✅ **Immutable Parameters**: Merkle root and token address are immutable once set
- ✅ **EIP-712 Compliance**: Signature verification uses standardized typed data hashing
- ✅ **Gas Optimization**: Merkle proofs minimize on-chain computation
- ⚠️ **No Recovery**: Once tokens are in the `MerkleAirdrop` contract, unclaimed tokens cannot be withdrawn (by design)
- ⚠️ **Whitelist Immutability**: The Merkle root (whitelist) cannot be updated after deployment

**Centralization Risks:**
- **Whitelist Generation**: The Merkle tree whitelist is generated off-chain. A malicious whitelist could be deployed, but users can verify their own eligibility before claiming.
- **Signature Verification**: Claims require valid EIP-712 signatures. If the signer's private key is compromised, unauthorized claims are possible for addresses in the Merkle proof.

**Dependencies:**
- **OpenZeppelin Contracts**: Uses audited libraries for ERC20, EIP-712, ECDSA, and Merkle proof verification
- **Murky**: External library for Merkle tree generation in tests

### Known Limitations

- **Merkle Root Immutability**: Cannot update the whitelist after deployment. A new contract must be deployed to change eligible addresses.
- **No Batch Claims**: Users can claim their own airdrop, or on behalf of others with their signature.
- **Merkle Leaf Hashing**: Current implementation uses `keccak256(bytes.concat(keccak256(abi.encode(account, amount))))` which is less gas-efficient than assembly-based methods. Consider using Solady's `EfficientHashLib` for production.
- **No Claim Deadline**: Users can claim their airdrop at any time after deployment. Consider adding a deadline in production environments.

## Gas Optimization

| Function           | Description                     | Optimizations                                                                                    |
| ------------------ | ------------------------------- | ------------------------------------------------------------------------------------------------ |
| `claim()`          | Main airdrop claim function     | Uses Merkle proofs (log n verification), EIP-712 signature verification, one-time claim tracking |
| `getDigest()`      | Returns EIP-712 typed data hash | Lazy evaluation, no storage reads                                                                |
| `getClaimStatus()` | Check if address has claimed    | Single storage read                                                                              |

**Key Gas Optimizations Implemented:**
- **Merkle Trees**: Instead of storing all eligible addresses (O(n) storage), uses Merkle root (O(1) storage) with O(log n) verification
- **Immutable Variables**: Token and Merkle root use `immutable` keyword, reducing SSTOREs and optimizing reads
- **SafeERC20**: Uses OpenZeppelin's `SafeERC20` for safe transfers with minimal overhead
- **No Loop-Based Operations**: Merkle proof verification is non-iterative
- **Single Storage Slot for Claims**: `s_hasClaimed` mapping efficiently tracks claimed status

**Gas Report:**

Generate a gas report for this project:

```bash
make gas-report
```

Generate gas snapshot:

```bash
forge snapshot
```

Compare gas changes:

```bash
forge snapshot --diff
```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Disclaimer:** This software is provided "as is", without warranty of any kind. Use at your own risk.

**Built with [Foundry](https://getfoundry.sh/)**