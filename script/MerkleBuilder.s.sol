// SPDX-License-Identifier: MIT

import {Script, console} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";
import {Merkle} from "murky/src/Merkle.sol";

pragma solidity ^0.8.27;

// Merkle proof generator script
// To use:
// 1. Run `forge script script/GenerateInput.s.sol` to generate the input file
// 2. Run `forge script script/Merkle.s.sol`
// 3. The output file will be generated in /script/target/output.json

contract MerkleBuilder is Script, ScriptHelper {
    using stdJson for string; // enables us to use the json cheatcodes for strings

    Merkle private m;
    string private inputPath;
    string private outputPath;
    string private elements;
    uint256 private count;
    string private output;
    bytes32[] private leafs;
    string[] private types;
    string[] private inputs;
    string[] private outputs;

    /// @dev Determine which input and output file to use then build merkle trees
    function run() public {
        // build local merkle tree
        inputPath = "/script/target/inputLocal.json";
        outputPath = "/script/target/outputLocal.json";
        _buildMerkle();
        // build testnet/mainnet merkle tree
        inputPath = "/script/target/input.json";
        outputPath = "/script/target/output.json";
        _buildMerkle();
    }

    /// @dev Read the input file and generate the Merkle proof, then write the output file
    function _buildMerkle() internal {
        // instance of the merkle contract from Murky
        m = new Merkle();
        elements = vm.readFile(string.concat(vm.projectRoot(), inputPath)); // get the absolute path
        types = elements.readStringArray(".types"); // gets the merkle tree leaf types from json using forge standard lib cheatcode
        count = elements.readUint(".count"); // get the number of leaf nodes

        // make three arrays the same size as the number of leaf nodes
        leafs = new bytes32[](count);
        inputs = new string[](count);
        outputs = new string[](count);

        console.log("Generating Merkle Proof for %s", inputPath);

        for (uint256 i = 0; i < count; ++i) {
            string[] memory input = new string[](types.length); // stringified data (address and string both as strings)
            bytes32[] memory data = new bytes32[](types.length); // actual data as a bytes32

            for (uint256 j = 0; j < types.length; ++j) {
                if (compareStrings(types[j], "address")) {
                    address value = elements.readAddress(_getValuesByIndex(i, j));
                    // you can't immediately cast straight to 32 bytes as an address is 20 bytes so first cast to uint160 (20 bytes) cast up to uint256 which is 32 bytes and finally to bytes32
                    data[j] = bytes32(uint256(uint160(value)));
                    input[j] = vm.toString(value);
                } else if (compareStrings(types[j], "uint")) {
                    uint256 value = vm.parseUint(elements.readString(_getValuesByIndex(i, j)));
                    data[j] = bytes32(value);
                    input[j] = vm.toString(value);
                }
            }
            // Create the hash for the merkle tree leaf node
            // abi encode the data array (each element is a bytes32 representation for the address and the amount)
            // Helper from Murky (ltrim64) Returns the bytes with the first 64 bytes removed
            // ltrim64 removes the offset and length from the encoded bytes. There is an offset because the array
            // is declared in memory
            // hash the encoded address and amount
            // bytes.concat turns from bytes32 to bytes
            // hash again because preimage attack
            leafs[i] = keccak256(bytes.concat(keccak256(ltrim64(abi.encode(data)))));
            // Converts a string array into a JSON array string.
            // store the corresponding values/inputs for each leaf node
            inputs[i] = stringArrayToString(input);
        }

        for (uint256 i = 0; i < count; ++i) {
            // get proof gets the nodes needed for the proof & stringify (from helper lib)
            string memory proof = bytes32ArrayToString(m.getProof(leafs, i));
            // get the root hash and stringify
            string memory root = vm.toString(m.getRoot(leafs));
            // get the specific leaf working on
            string memory leaf = vm.toString(leafs[i]);
            // get the singified input (address, amount)
            string memory input = inputs[i];

            // generate the Json output file (tree dump)
            outputs[i] = _generateJsonEntries(input, proof, root, leaf);
        }

        // stringify the array of strings to a single string
        output = stringArrayToArrayString(outputs);
        // write to the output file the stringified output json (tree dump)
        vm.writeFile(string.concat(vm.projectRoot(), outputPath), output);

        console.log("DONE: The output is found at %s", outputPath);
    }

    /// @dev Returns the JSON path of the input file
    // output file output ".values.some-address.some-amount"
    function _getValuesByIndex(uint256 i, uint256 j) internal pure returns (string memory) {
        return string.concat(".values.", vm.toString(i), ".", vm.toString(j));
    }

    /// @dev Generate the JSON entries for the output file
    function _generateJsonEntries(
        string memory _inputs,
        string memory _proof,
        string memory _root,
        string memory _leaf
    )
        internal
        pure
        returns (string memory)
    {
        string memory result = string.concat(
            "{",
            "\"inputs\":",
            _inputs,
            ",",
            "\"proof\":",
            _proof,
            ",",
            "\"root\":\"",
            _root,
            "\",",
            "\"leaf\":\"",
            _leaf,
            "\"",
            "}"
        );

        return result;
    }
}
