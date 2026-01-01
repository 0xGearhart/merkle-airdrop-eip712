// SPDX-License-Identifier: MIT

import {Deploy} from "../../script/Deploy.s.sol";
import {CodeConstants} from "../../script/HelperConfig.s.sol";
import {AirdropToken} from "../../src/AirdropToken.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {Test} from "forge-std/Test.sol";

pragma solidity ^0.8.27;

contract MerkleAirdropTest is Test, CodeConstants {
    Deploy deploy;
    MerkleAirdrop merkleAirdrop;
    AirdropToken airdropToken;

    bytes32 merkleRoot;
    address user1;
    uint256 user1PrivKey;
    address user2;
    uint256 user2PrivKey;

    bytes32[] emptyProof;
    bytes32[] user1Proof = [
        bytes32(0x8ebcc963f0588d1ded1ebd0d349946755f27e95d1917f9427a207d8935e04d4b),
        bytes32(0xf4216065bf6ac971b2f1ba0fef5920345dcaeceabf5f200030a1cd530dd44a89),
        bytes32(0x2aadccb0553b8c9968b78ca32bb891c1dd527eb553ff5b19aa35560e4757e5b0)
    ];
    bytes32[] user2Proof = [
        bytes32(0xef54b0c83407e0c74021e9c900344391f8b30fb6c98e7689f3c6015840959d08),
        bytes32(0xf4216065bf6ac971b2f1ba0fef5920345dcaeceabf5f200030a1cd530dd44a89),
        bytes32(0x2aadccb0553b8c9968b78ca32bb891c1dd527eb553ff5b19aa35560e4757e5b0)
    ];

    function setUp() public {
        deploy = new Deploy();
        (airdropToken, merkleAirdrop) = deploy.run();
        merkleRoot = merkleAirdrop.getMerkleRoot();
        (user1, user1PrivKey) = makeAddrAndKey("user1");
        (user2, user2PrivKey) = makeAddrAndKey("user2");
    }
}
