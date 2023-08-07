// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.19;

// You've been approved to claim 1 ETH. Claim more than your fair share.
contract DoubleTake {
    address signer = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    mapping(bytes => bool) used;
    mapping(address => uint256) public allowance;

    constructor() payable {}

    function claimAirdrop(address user, uint256 amount, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 hash_ = keccak256(abi.encode(user, amount));
        bytes memory signature = abi.encodePacked(v, r, s);

        require(signer == ecrecover(hash_, v, r, s), "signature not accepted");
        require(!used[signature], "signature already used");
        used[signature] = true;

        (bool ok, ) = user.call{value: amount}("");
        require(ok, "transfer failed");
    }
}