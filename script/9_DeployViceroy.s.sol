// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Script} from "@forge-std/Script.sol";
import {OligarchyNFT, Governance } from "@main/Viceroy.sol";
import {ViceroyAttacker} from "@main/ViceroyAttacker.sol";

// import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract DeployViceroyScript is Script {
    OligarchyNFT oligarch;
    ViceroyAttacker viceroyAttacker;
    Governance governance;

    function run() public {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // string memory mnemonic = vm.envString("MNEMONIC");

        // address is already funded with ETH
        string memory mnemonic ="test test test test test test test test test test test junk";
        uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
        uint256 attackerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 2); //  address = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC

        vm.startBroadcast(attackerPrivateKey);

        viceroyAttacker = new ViceroyAttacker();

        vm.stopBroadcast();
        vm.startBroadcast(deployerPrivateKey);

        oligarch = new OligarchyNFT(address(viceroyAttacker));
        governance = new Governance{value : 1 ether}(oligarch);

        vm.stopBroadcast();
    }
}