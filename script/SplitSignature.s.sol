// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";

contract SplitSignature is Script {
    error SplitSignature__InvalidSignatureLength();

    string inputPath = "/script/target/signature.txt";

    function run() external view {
        // string memory signatureString = vm.readFile("signature.txt");
        string memory signatureString = vm.readFile(string.concat(vm.projectRoot(), inputPath));
        bytes memory signature = vm.parseBytes(signatureString);
        (uint8 v, bytes32 r, bytes32 s) = _splitSignature(signature);
        console.log("v value:");
        console.log(v);
        console.log("r value:");
        console.logBytes32(r);
        console.log("s value:");
        console.logBytes32(s);
    }

    function _splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert SplitSignature__InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
