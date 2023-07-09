// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {DeployReadOnlyScript} from "@script/12_DeployReadOnly.s.sol";
import {ReadOnlyPool, VulnerableDeFiContract} from "@main/ReadOnly.sol";
import {ReadOnlyAttacker} from "@main/ReadOnlyAttacker.sol";

contract ReadOnlyPoolTest is Test, DeployReadOnlyScript {
    string mnemonic = "test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    uint256 attackerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 2); //  address = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC

    address deployer = vm.addr(deployerPrivateKey);
    address attacker = vm.addr(attackerPrivateKey);

    ReadOnlyAttacker readonlyAttacker;

    function setUp() public {
        vm.label(deployer, "Deployer");
        vm.label(attacker, "Attacker");

        vm.deal(deployer, 101 ether);
        vm.deal(attacker, 2 ether);

        DeployReadOnlyScript.run();
    }

    modifier beforeEach() {
        vm.startPrank(deployer);

        readOnlyPool.addLiquidity{value: 100 ether}();
        readOnlyPool.earnProfit{value: 1 ether}();
        vulnerableDeFiContract.snapshotPrice();

        vm.stopPrank();
        _;
    }

    function test_isSolved() public beforeEach {
        vm.startPrank(attacker);

        readonlyAttacker =
            new ReadOnlyAttacker{value : 1.1 ether}( address(readOnlyPool), address(vulnerableDeFiContract));
        readonlyAttacker.attack();

        assertEq(vulnerableDeFiContract.lpTokenPrice(), 0 ether, "snapshotPrice should be zero");

        vm.stopPrank();
    }
}
