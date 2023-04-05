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

define local_network
http://127.0.0.1:$1
endef