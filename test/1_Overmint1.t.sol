// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {DeployOvermint1Script} from "@script/1_DeployOvermint1.s.sol";
import {Overmint1} from "@main/Overmint1.sol";
import {Overmint1Attacker} from "@main/Overmint1Attacker.sol";

contract Overmint1Test is Test, DeployOvermint1Script {
    address public attacker = address(11);

    Overmint1Attacker overmint1Attacker;

    function setUp() public {

        vm.deal(attacker, 1 ether);
        vm.label(attacker, "Attacker");

        DeployOvermint1Script.run();
    }

    function test_isSolved() public {
        vm.startPrank(attacker);

        assertEq(overmint1Challenge.success(attacker), false );

        overmint1Attacker = new Overmint1Attacker(address(overmint1Challenge));
        overmint1Attacker.attack();

        assertEq(overmint1Challenge.success(attacker), true );

        vm.stopPrank(  );
    }

}