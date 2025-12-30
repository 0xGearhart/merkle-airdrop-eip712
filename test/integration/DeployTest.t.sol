// SPDX-License-Identifier: MIT

import {Deploy} from "../../script/Deploy.s.sol";
import {AirdropToken} from "../../src/AirdropToken.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {Test} from "forge-std/Test.sol";

pragma solidity ^0.8.27;

contract DeployTest is Test {
    Deploy deploy;
    MerkleAirdrop merkleAirdrop;
    AirdropToken airdropToken;

    function setUp() public {
        deploy = new Deploy();
        (airdropToken, merkleAirdrop) = deploy.run();
    }
}
