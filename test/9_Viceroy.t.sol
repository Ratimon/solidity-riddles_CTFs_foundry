// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {DeployViceroyScript} from "@script/9_DeployViceroy.s.sol";
// import {Viceroy} from "@main/Viceroy.sol";

interface IGovernance {
    function communityWallet() external returns (address);
}


contract ViceroyTest is Test, DeployViceroyScript {

    string mnemonic ="test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

    address deployer = vm.addr(deployerPrivateKey);
    address public attacker = address(11);

    function setUp() public {
        vm.deal(attacker, 1 ether);
        vm.label(attacker, "Attacker");

        vm.deal(deployer, 1 ether);

        DeployViceroyScript.run();
    }

    modifier beforeEach() {
        vm.startPrank(deployer);

        assertEq( address(IGovernance(address(governance)).communityWallet()).balance , 1 ether);

        vm.stopPrank(  );
        _;
    }

    function test_isSolved() public beforeEach {
        vm.startPrank(attacker);

        // assertEq( address(IGovernance(address(governance)).communityWallet()).balance , 0 ether);

        vm.stopPrank(  );
    }

}