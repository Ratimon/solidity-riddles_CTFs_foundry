# spin node
anvil-node:
	anvil --chain-id 1337

anvil-node-auto:
	anvil --chain-id 1337 --block-time 5

1-deploy-overmint1:
	forge script DeployOvermint1Script --rpc-url $(call local_network,8545)  -vvvv --broadcast; \

1-unit:
	forge test --match-path test/1_Overmint1.t.sol -vvv

2-deploy-overmint2:
	forge script DeployOvermint2Script --rpc-url $(call local_network,8545)  -vvvv --broadcast; \

2-unit:
	forge test --match-path test/2_Overmint2.t.sol -vvv

3-deploy-overmint1-erc1155:
	forge script DeployOvermint1_ERC1155Script --rpc-url $(call local_network,8545)  -vvvv --broadcast; \

3-unit:
	forge test --match-path test/3_Overmint1-ERC1155.t.sol -vvv

4-deploy-forwarder:
	forge script DeployForwarderScript --rpc-url $(call local_network,8545)  -vvvv --broadcast; \

4-unit:
	forge test --match-path test/4_Forwarder.t.sol -vvv

5-deploy-assignvotes:
	forge script DeployAssignVotesScript --rpc-url $(call local_network,8545)  -vvvv --broadcast; \

5-unit:
	forge test --match-path test/5_AssignVotes.t.sol -vvv

6-deploy-overmint3:
	forge script DeployOvermint3Script --rpc-url $(call local_network,8545)  -vvvv --broadcast; \

6-unit:
	forge test --match-path test/6_Overmint3.t.sol -vvv

7-deploy-democracy:
	forge script DeployDemocracyScript --rpc-url $(call local_network,8545)  -vvvv --broadcast; \

7-unit:
	forge test --match-path test/7_Democracy.t.sol -vvv

8-deploy-delete:
	forge script DeployDeleteUserScript --rpc-url $(call local_network,8545)  -vvvv --broadcast; \

8-unit:
	forge test --match-path test/8_DeleteUser.t.sol -vvv

9-deploy-viceroy:
	forge script DeployViceroyScript --rpc-url $(call local_network,8545)  -vvvv --broadcast; \

9-unit:
	forge test --match-path test/9_Viceroy.t.sol -vvv

10-deploy-rewardtoken:
	forge script DeployRewardTokenScript --rpc-url $(call local_network,8545)  -vvvv --broadcast; \

10-unit:
	forge test --match-path test/10_RewardToken.t.sol -vvv

11-deploy-flashloan:
	forge script DeployFlashloanScript --rpc-url $(call local_network,8545)  -vvvv --broadcast; \

11-unit:
	forge test --match-path test/11_Flashloan.t.sol -vvv

12-deploy-readonly:
	forge script DeployReadOnlyScript --rpc-url $(call local_network,8545)  -vvvv --broadcast; \

12-unit:
	forge test --match-path test/12_ReadOnly.t.sol -vvv

12-deploy-doubletake:
	forge script DeployDoubleTakeScript --rpc-url $(call local_network,8545)  -vvvv --broadcast; \

13-unit:
	forge test --match-path test/13_DoubleTake.t.sol -vvv

define local_network
http://127.0.0.1:$1
endef