// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {DeployOvermint1Script} from "@script/1_DeployOvermint1.s.sol";
import {Overmint1} from "@main/Overmint1.sol";
import {Overmint1Attacker} from "@main/Overmint1Attacker.sol";

contract Overmint1Test is Test, DeployOvermint1Script {

    string mnemonic ="test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

    address deployer = vm.addr(deployerPrivateKey);
    address public attacker = address(11);


    Overmint1Attacker overmint1Attacker;

    function setUp() public {

        vm.deal(attacker, 1 ether);
        vm.label(attacker, "Attacker");

        DeployOvermint1Script.run();
    }

    function test_isSolved() public {
        vm.startPrank(attacker);

        overmint1Attacker = new Overmint1Attacker(address(overmint1Challenge));
        overmint1Attacker.attack();

        assertEq(overmint1Challenge.success(attacker), true );

        vm.stopPrank(  );
    }

}