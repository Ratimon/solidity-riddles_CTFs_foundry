// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Script} from "@forge-std/Script.sol";
import {OligarchyNFT} from "@main/Viceroy.sol";
import {ViceroyAttacker} from "@main/ViceroyAttacker.sol";

contract DeployViceroyScript is Script {
    OligarchyNFT oligarch;
    ViceroyAttacker viceroyAttacker; 

    function run() public {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // string memory mnemonic = vm.envString("MNEMONIC");

        // address is already funded with ETH
        string memory mnemonic ="test test test test test test test test test test test junk";
        uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

        vm.startBroadcast(deployerPrivateKey);

        viceroyAttacker = new ViceroyAttacker();
        oligarch = new OligarchyNFT(address(viceroyAttacker));

        vm.stopBroadcast();
    }
}