// SPDX-License-Identifier: MIT

import {CodeConstants} from "./HelperConfig.s.sol";
import {Script, console} from "forge-std/Script.sol";

pragma solidity ^0.8.27;

// Merkle tree input file generator script
contract GenerateInput is Script, CodeConstants {
    string[] types = new string[](2);
    string[] whitelist;
    uint256 count;
    string private inputPath;

    function run() public {
        types[0] = "address";
        types[1] = "uint";

        // build local whitelist and save to inputLocal.json
        inputPath = "/script/target/inputLocal.json";
        whitelist = new string[](5);
        whitelist[0] = "0x29E3b139f4393aDda86303fcdAa35F60Bb7092bF"; // makeAddrAndKey("user1")
        whitelist[1] = "0x537C8f3d3E18dF5517a58B3fB9D9143697996802"; // makeAddrAndKey("user2")
        whitelist[2] = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        whitelist[3] = "0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd";
        whitelist[4] = "0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D";
        count = whitelist.length;
        string memory inputLocal = _createJSON();
        // write to the output file the stringified output json tree dump
        vm.writeFile(string.concat(vm.projectRoot(), inputPath), inputLocal);
        console.log("DONE: The local output is found at %s", inputPath);

        // build testnet/mainnet whitelist and save to input.json
        inputPath = "/script/target/input.json";
        whitelist = new string[](5);
        whitelist[0] = vm.toString(vm.envAddress("DEFAULT_KEY_ADDRESS")); // default account address for testnet
        whitelist[1] = vm.toString(vm.envAddress("SECONDARY_ADDRESS")); // secondary address for testnet
        whitelist[2] = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        whitelist[3] = "0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd";
        whitelist[4] = "0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D";
        count = whitelist.length;
        string memory input = _createJSON();
        // write to the output file the stringified output json tree dump
        vm.writeFile(string.concat(vm.projectRoot(), inputPath), input);
        console.log("DONE: The output is found at %s", inputPath);
    }

    function _createJSON() internal view returns (string memory) {
        string memory countString = vm.toString(count); // convert count to string
        string memory amountString = vm.toString(AIRDROP_CLAIM_AMOUNT); // convert amount to string
        string memory json = string.concat('{ "types": ["address", "uint"], "count":', countString, ',"values": {');
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (i == whitelist.length - 1) {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0":',
                    '"',
                    whitelist[i],
                    '"',
                    ', "1":',
                    '"',
                    amountString,
                    '"',
                    " }"
                );
            } else {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0":',
                    '"',
                    whitelist[i],
                    '"',
                    ', "1":',
                    '"',
                    amountString,
                    '"',
                    " },"
                );
            }
        }
        json = string.concat(json, "} }");

        return json;
    }
}
