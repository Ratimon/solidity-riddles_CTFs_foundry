// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {DeployOvermint1_ERC1155Script} from "@script/3_DeployOvermint1_ERC1155.s.sol";
import {Overmint1_ERC1155} from "@main/Overmint1-ERC1155.sol";
import {Overmint1_ERC1155Attacker} from "@main/Overmint1-ERC1155Attacker.sol";

contract Overmint1_ERC1155Test is Test, DeployOvermint1_ERC1155Script {

    string mnemonic ="test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

    address deployer = vm.addr(deployerPrivateKey);
    address public attacker = address(11);

    Overmint1_ERC1155Attacker erc1155Attacker;

    function setUp() public {

        vm.deal(attacker, 1 ether);
        vm.label(attacker, "Attacker");

        DeployOvermint1_ERC1155Script.run();
    }

    function test_isSolved() public {
        vm.startPrank(attacker);

        uint256 id = 0;

        erc1155Attacker = new Overmint1_ERC1155Attacker(address(erc1155Challenge), id);
        erc1155Attacker.attack();

        assertEq(erc1155Challenge.success(attacker, id), true );

        vm.stopPrank(  );
    }

}