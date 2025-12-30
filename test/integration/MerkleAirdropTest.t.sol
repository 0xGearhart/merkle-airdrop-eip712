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

    address user1;
    address user1PrivKey;
    address user2;
    address user2PrivKey;

    function setUp() public {
        deploy = new Deploy();
        (airdropToken, merkleAirdrop) = deploy.run();

        (user1, user1PrivKey) = makeAddrAndKey("user1");
        (user2, user2PrivKey) = makeAddrAndKey("user2");
    }
}
