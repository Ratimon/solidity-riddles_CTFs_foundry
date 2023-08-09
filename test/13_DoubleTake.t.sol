// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {DeployDoubleTakeScript} from "@script/13_DeployDoubleTake.s.sol";
import {DoubleTake} from "@main/DoubleTake.sol";
import {ForceAttacker} from "@main/DoubleTakeAttacker.sol";

contract DoubleTakeTest is Test, DeployDoubleTakeScript {
    string mnemonic = "test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    uint256 attackerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 2); //  address = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC

    address deployer = vm.addr(deployerPrivateKey);
    address attacker = vm.addr(attackerPrivateKey);

    ClaimAirdropSignature sigUtils;
    ForceAttacker forceAttacker;

    function setUp() public {
        vm.label(deployer, "Deployer");
        vm.label(attacker, "Attacker");

        vm.deal(deployer, 2 ether);
        vm.deal(attacker, 0.1 ether);

        sigUtils = new ClaimAirdropSignature();
        DeployDoubleTakeScript.run();
    }

    modifier beforeEach() {
        vm.startPrank(attacker);

        assertEq(address(doubleTake).balance, 2 ether, "challenge balance should equal the full amount");

        ClaimAirdropSignature.ClaimAirdrop memory claim = ClaimAirdropSignature.ClaimAirdrop({
            user: 0x5Cd705F118aD9357Ac8330f48AdA7A60F3efc200,
            amount: 1 ether
        });

        bytes32 digestClaim = sigUtils.getStructHash(claim);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(deployerPrivateKey, digestClaim);

        doubleTake.claimAirdrop(0x5Cd705F118aD9357Ac8330f48AdA7A60F3efc200, 1 ether, v, r, s);

        assertEq(address(doubleTake).balance, 1 ether, "challenge balance should equal balance after the first claim");

        vm.stopPrank();
        _;
    }

    function test_isSolved() public beforeEach {
        vm.startPrank(attacker);

        forceAttacker = new ForceAttacker{value : 0.1 ether}(address(doubleTake));
        forceAttacker.attack();

        ClaimAirdropSignature.ClaimAirdrop memory claim = ClaimAirdropSignature.ClaimAirdrop({
            user: 0x5Cd705F118aD9357Ac8330f48AdA7A60F3efc200,
            amount: 1.1 ether
        });

        bytes32 digestClaim = sigUtils.getStructHash(claim);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(deployerPrivateKey, digestClaim);

        doubleTake.claimAirdrop(0x5Cd705F118aD9357Ac8330f48AdA7A60F3efc200, 1.1 ether, v, r, s);
        assertEq(address(attacker).balance, 0 ether, "challenge balance should equal zero");

        vm.stopPrank();
    }
}

contract ClaimAirdropSignature {

    struct ClaimAirdrop {
        address user;
        uint256 amount;
    }

    function getStructHash(ClaimAirdrop memory _claimAirdrop) public pure returns (bytes32) {
        return keccak256(
            abi.encode( _claimAirdrop.user, _claimAirdrop.amount)
        );
    }

}