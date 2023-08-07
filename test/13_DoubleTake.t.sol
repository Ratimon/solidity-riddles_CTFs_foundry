// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";

import {DeployDoubleTakeScript} from "@script/13_DeployDoubleTake.s.sol";
import {DoubleTake} from "@main/DoubleTake.sol";

contract DoubleTakeTest is Test, DeployDoubleTakeScript {
    string mnemonic = "test test test test test test test test test test test junk";
    uint256 deployerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    uint256 attackerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 2); //  address = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC

    address deployer = vm.addr(deployerPrivateKey);
    address attacker = vm.addr(attackerPrivateKey);

    ClaimAirdropSignature sigUtils;


    function setUp() public {
        vm.label(deployer, "Deployer");
        vm.label(attacker, "Attacker");

        vm.deal(deployer, 2 ether);
        vm.deal(attacker, 1 ether);

        DeployDoubleTakeScript.run();

        sigUtils = new ClaimAirdropSignature(address(doubleTake));
    }

    modifier beforeEach() {
        vm.startPrank(attacker);

        ClaimAirdropSignature.ClaimAirdrop memory claim = ClaimAirdropSignature.ClaimAirdrop({
            user: 0x5Cd705F118aD9357Ac8330f48AdA7A60F3efc200,
            amount: 1 ether
        });

        bytes32 digestClaim = sigUtils.getStructHash2(claim);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(deployerPrivateKey, digestClaim);

         doubleTake.claimAirdrop(0x5Cd705F118aD9357Ac8330f48AdA7A60F3efc200, 1 ether, v, r, s);

        vm.stopPrank();
        _;
    }

    function test_isSolved() public beforeEach {
        vm.startPrank(attacker);

        vm.stopPrank();
    }


}

contract ClaimAirdropSignature {
    // bytes32 public constant DOMAIN_TYPEHASH =
    // keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
    // address claim;
    // uint256 private immutable _deploymentChainId;
    // bytes32 private immutable _deploymentDomainSeparator;

    constructor(address _claim) {
        // claim = _claim;
        // uint256 chainId;
        // //solhint-disable-next-line no-inline-assembly
        // assembly {
        //     chainId := chainid()
        // }
        // _deploymentChainId = chainId;
        // _deploymentDomainSeparator = _calculateDomainSeparator(chainId);
    }

    /// @dev Return the DOMAIN_SEPARATOR.
    // function DOMAIN_SEPARATOR() external view returns (bytes32) {
    //     return _DOMAIN_SEPARATOR();
    // }

    // cast keccak "claimAirdrop(address,amount)"
    /// @dev keccak256("claimAirdrop(address user,uint256 amount)");
    bytes32 public constant CLAIMAIRDROP_TYPEHASH = 0xd2d64d48e2b7ea835666b070a2e1c17f07a8e6962b28a4c88ee1388e1d820b1c;

    struct ClaimAirdrop {
        address user;
        uint256 amount;
    }

    // /// @dev Computes the hash of a claimAirdrop
    // /// @param _claimAirdrop The approval to execute on-chain
    // /// @return The encoded claimAirdrop
    // function getStructHash(ClaimAirdrop memory _claimAirdrop) internal pure returns (bytes32) {
    //     return keccak256(
    //         abi.encode(CLAIMAIRDROP_TYPEHASH, _claimAirdrop.user, _claimAirdrop.amount)
    //     );
    // }


    function getStructHash2(ClaimAirdrop memory _claimAirdrop) public pure returns (bytes32) {
        return keccak256(
            abi.encode( _claimAirdrop.user, _claimAirdrop.amount)
        );
    }

    // /// @notice Computes the hash of a fully encoded EIP-712 message for the domain
    // /// @param _claimAirdrop The approval to execute on-chain
    // /// @return The digest to sign and use to recover the signer
    // function getTypedDataHash(ClaimAirdrop memory _claimAirdrop) public view returns (bytes32) {
    //     return keccak256(abi.encodePacked("\x19\x01", _DOMAIN_SEPARATOR(), getStructHash(_claimAirdrop)));
    // }

    // /// @dev Return the DOMAIN_SEPARATOR.
    // function _DOMAIN_SEPARATOR() internal view returns (bytes32) {
    //     uint256 chainId;
    //     //solhint-disable-next-line no-inline-assembly
    //     assembly {
    //         chainId := chainid()
    //     }

    //     // in case a fork happen, to support the chain that had to change its chainId,, we compute the domain operator
    //     return chainId == _deploymentChainId ? _deploymentDomainSeparator : _calculateDomainSeparator(chainId);
    // }

    // /// @dev Calculate the DOMAIN_SEPARATOR.
    // function _calculateDomainSeparator(uint256 chainId) private view returns (bytes32) {
    //     return keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256("ClaimAirdrop"), chainId, claim));
    // }
}