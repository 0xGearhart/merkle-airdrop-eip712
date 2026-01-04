-include .env

.PHONY: all clean remove install update snapshot coverage-report gas-report anvil deploy claim-airdrop get-digest sign-digest merkle claim-airdrop-with-full-sig split-signature

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install cyfrin/foundry-devops@0.2.2 && forge install foundry-rs/forge-std@v1.11.0 && forge install openzeppelin/openzeppelin-contracts@v5.5.0 && forge install dmfxyz/murky@v0.1.0

# Update Dependencies
update:; forge update

# Create test coverage report and save to .txt file
coverage-report :; forge coverage --report debug > coverage.txt

# Generate Gas Snapshot
snapshot :; forge snapshot

# Generate table showing gas cost for each function
gas-report :; forge test --gas-report > gas.txt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network eth MAINNET,$(ARGS)),--network eth MAINNET)
	NETWORK_ARGS := --rpc-url $(ETH_MAINNET_RPC_URL) --account defaultKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

ifeq ($(findstring --network eth sepolia,$(ARGS)),--network eth sepolia)
	NETWORK_ARGS := --rpc-url $(ETH_SEPOLIA_RPC_URL) --account defaultKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

ifeq ($(findstring --network arb MAINNET,$(ARGS)),--network arb MAINNET)
	NETWORK_ARGS := --rpc-url $(ARB_MAINNET_RPC_URL) --account defaultKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

ifeq ($(findstring --network arb sepolia,$(ARGS)),--network arb sepolia)
	NETWORK_ARGS := --rpc-url $(ARB_SEPOLIA_RPC_URL) --account defaultKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

ifeq ($(findstring --network base MAINNET,$(ARGS)),--network base MAINNET)
	NETWORK_ARGS := --rpc-url $(BASE_MAINNET_RPC_URL) --account defaultKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

ifeq ($(findstring --network base sepolia,$(ARGS)),--network base sepolia)
	NETWORK_ARGS := --rpc-url $(BASE_SEPOLIA_RPC_URL) --account defaultKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

# Generate input in json format with GenerateInput script and save to input.json file then build merkle tree from generated input with MerkleBuilder script and save to output.json file
merkle:
	@forge script script/GenerateInput.s.sol:GenerateInput && forge script script/MerkleBuilder.s.sol:MerkleBuilder

# deploy airdrop token and airdrop claim contract
deploy:
	@forge script script/Deploy.s.sol:Deploy $(NETWORK_ARGS)

# for streamlined digest creation, signing, and claiming programmatically
claim-airdrop:
	@forge script script/Interactions.s.sol:ClaimAirdrop $(NETWORK_ARGS)

# for use with full bytes signature object that needs to be split into v, r, and s components before claim
# get full signature for this script with make targets below (get-digest, sign-digest)
claim-airdrop-with-full-sig:
	@forge script script/Interactions.s.sol:ClaimAirdropWithUnsplitSignature $(NETWORK_ARGS)

# get hashed message digest with forge cast. Hardcoded for anvil default sender as example. Modify and use in terminal as needed
# parameters => address of deployed MerkleAirdrop contract to call, function sig to be called("getDigest(address,uint256)"), whitelisted claiming address, amount to claim, rpc url to execute call on
get-digest:
	cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "getDigest(address,uint256)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 25000000000000000000 --rpc-url http://localhost:8545

# using output from get-digest above ^. Hardcoded for anvil default sender as example. Modify and use in terminal as needed
# --no-hash since digest is already hashed in getDigest call before signing
# DO NOT USE PRIVATE KEY IN PLAIN TEXT OUTSIDE OF ANVIL DEFAULT ACCOUNTS. Replace with --account defaultKey when using encrypted keys
# ignore "0x" prefix of signature output when copying to use in ClaimAirdropWithUnsplitSignature script
sign-digest:
	cast wallet sign --no-hash 0x72030e6f8a1f71c69d8cc6b6aed9da40dbd003ef50c3ba0549f0d0afffafb211 --private-key $(DEFAULT_ANVIL_KEY)

# split full signature saved to signature.txt file
split-signature:
	@forge script script/SplitSignature.s.sol:SplitSignature