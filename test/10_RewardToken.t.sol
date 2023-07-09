// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {DeployRewardTokenScript} from "@script/10_DeployRewardToken.s.sol";
import {RewardTokenAttacker} from "@main/RewardTokenAttacker.sol";

contract RewardTokenTest is Test, DeployRewardTokenScript {
    string mnemonic = "test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    uint256 attackerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 2); //  address = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC

    address deployer = vm.addr(deployerPrivateKey);
    address attacker = vm.addr(attackerPrivateKey);

    RewardTokenAttacker rewardtokenAttacker;

    function setUp() public {
        vm.label(deployer, "Deployer");
        vm.label(attacker, "Attacker");

        vm.deal(deployer, 1 ether);
        vm.deal(attacker, 1 ether);

        vm.warp(block.timestamp);

        DeployRewardTokenScript.run();
    }

    modifier beforeEach() {
        vm.startPrank(deployer);

        depositoor.setRewardToken(rewardToken);

        assertEq(rewardToken.balanceOf(address(rewardtokenAttacker)), 0 ether);
        assertEq(rewardToken.balanceOf(address(depositoor)), 100 ether);

        vm.stopPrank();
        _;
    }

    function test_isSolved() public beforeEach {
        vm.startPrank(attacker);

        rewardtokenAttacker = new RewardTokenAttacker(address(depositoor), address(rewardToken), address(nftToStake));

        nftToStake.approve(address(rewardtokenAttacker), 42);
        nftToStake.safeTransferFrom(attacker, address(rewardtokenAttacker), 42);

        rewardtokenAttacker.stake();
        vm.warp(block.timestamp + 10 days);
        rewardtokenAttacker.attack();

        assertEq(
            rewardToken.balanceOf(address(rewardtokenAttacker)),
            100 ether,
            "Balance of attacking contract must be 100e18 tokens"
        );
        assertEq(rewardToken.balanceOf(address(depositoor)), 0 ether, "Attacked contract must be fully drained");

        vm.stopPrank();
    }
}
