echo Which script do you want to run \(eg Greeter\)?
read contract

source .env && forge script test/foundry/scripts/${contract}.s.sol:${contract} --rpc-url $ETH_RPC_URL -vvvv --broadcast  --verify --private-key $PRIVKEY --etherscan-api-key $ETHERSCAN_API_KEY