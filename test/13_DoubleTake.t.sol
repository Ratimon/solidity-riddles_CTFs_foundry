// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {DeployDoubleTakeScript} from "@script/13_DeployDoubleTake.s.sol";
import {DoubleTake} from "@main/DoubleTake.sol";

contract DoubleTakeTest is Test, DeployDoubleTakeScript {
    string mnemonic = "test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    uint256 attackerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 2); //  address = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC

    address deployer = vm.addr(deployerPrivateKey);
    address attacker = vm.addr(attackerPrivateKey);


    function setUp() public {
        vm.label(deployer, "Deployer");
        vm.label(attacker, "Attacker");

        vm.deal(deployer, 2 ether);
        vm.deal(attacker, 1 ether);

        DeployDoubleTakeScript.run();
    }

    modifier beforeEach() {
        vm.startPrank(deployer);

        vm.stopPrank();
        _;
    }

    function test_isSolved() public beforeEach {
        vm.startPrank(attacker);

        vm.stopPrank();
    }
}
