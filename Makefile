# spin node
anvil-node:
	anvil --chain-id 1337

anvil-node-auto:
	anvil --chain-id 1337 --block-time 5

1-deploy-overmint1:
	forge script DeployOvermint1Script --rpc-url $(call local_network,8545)  -vvvv --broadcast; \

1-unit:
	forge test --match-path test/Overmint1.t.sol -vvv

2-deploy-overmint2:
	forge script DeployOvermint2Script --rpc-url $(call local_network,8545)  -vvvv --broadcast; \

define local_network
http://127.0.0.1:$1
endef