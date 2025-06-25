# Foundry Fund Me


# About

This is a minimal project allowing users to fund the contract owner with donations.
- The smart contract accepts ETH as donations, denominated in USD. 
- Donations have a minimal USD value, otherwise they are rejected. 
- The value is priced using a Chainlink price feed, and the smart contract keeps track of doners in case they are to be rewarded in the future.


- [Foundry Fund Me](#foundry-fund-me)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
    - [Optional Gitpod](#optional-gitpod)
- [Usage](#usage)
  - [Deploy](#deploy)
  - [Testing](#testing)
    - [Test Coverage](#test-coverage)
  - [Local zkSync](#local-zksync)
    - [(Additional) Requirements](#additional-requirements)
    - [Setup local zkSync node](#setup-local-zksync-node)
    - [Deploy to local zkSync node](#deploy-to-local-zksync-node)
- [Deployment to a testnet or mainnet](#deployment-to-a-testnet-or-mainnet)
  - [Scripts](#scripts)
    - [Withdraw](#withdraw)
  - [Estimate gas](#estimate-gas)
- [Formatting](#formatting)
- [Frontend (Nuxt/Web) Integration](#frontend-nuxtweb-integration)
  - [Running the Frontend](#running-the-frontend)
  - [Connecting to the Smart Contracts](#connecting-to-the-smart-contracts)
  - [Dependencies](#dependencies)
- [Additional Info:](#additional-info)
  - [Let's talk about what "Official" means](#lets-talk-about-what-official-means)
  - [Summary](#summary)
- [Thank you!](#thank-you)

# Usage

## Deploy

```
forge script script/DeployFundMe.s.sol
```

## Testing

```
forge test
```

or 

```

forge test --mt testFunctionName
```

or

```
forge test --fork-url $SEPOLIA_RPC_URL
```

### Test Coverage

```
forge coverage
```

## Local zkSync 

The instructions here will allow you to work with this repo on zkSync.

### (Additional) Requirements 

In addition to the requirements above, you'll need:
- [foundry-zksync](https://github.com/matter-labs/foundry-zksync)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.0.2 (816e00b 2023-03-16T00:05:26.396218Z)`.

### Setup local zkSync node 

Run the following:

```bash
npx zksync-cli dev config
```

And select: `In memory node` and do not select any additional modules.

Then run:
```bash
npx zksync-cli dev start
```

And you'll get an output like:
```
In memory node started v0.1.0-alpha.22:
 - zkSync Node (L2):
  - Chain ID: 260
  - RPC URL: http://127.0.0.1:8011
  - Rich accounts: https://era.zksync.io/docs/tools/testing/era-test-node.html#use-pre-configured-rich-wallets
```

### Deploy to local zkSync node

```bash
make deploy-zk
```

This will deploy a mock price feed and a fund me contract to the zkSync node.

# Deployment to a testnet or mainnet

1. Setup environment variables

You'll want to set your `SEPOLIA_RPC_URL` and `PRIVATE_KEY` as environment variables. You can add them to a `.env` file, similar to what you see in `.env.example`.

- `PRIVATE_KEY`: The private key of your account (like from [metamask](https://metamask.io/)). **NOTE:** FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.
  - You can [learn how to export it here](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key).
- `SEPOLIA_RPC_URL`: This is url of the sepolia testnet node you're working with. You can get setup with one for free from [Alchemy](https://alchemy.com/?a=673c802981)

Optionally, add your `ETHERSCAN_API_KEY` if you want to verify your contract on [Etherscan](https://etherscan.io/).

2. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link/) and get some testnet ETH. You should see the ETH show up in your metamask.

3. Deploy

```
forge script script/DeployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

## Scripts

After deploying to a testnet or local net, you can run the scripts. 

Using cast deployed locally example: 

```
cast send <FUNDME_CONTRACT_ADDRESS> "fund()" --value 0.1ether --private-key <PRIVATE_KEY>
```

or
```
forge script script/Interactions.s.sol:FundFundMe --rpc-url sepolia  --private-key $PRIVATE_KEY  --broadcast
forge script script/Interactions.s.sol:WithdrawFundMe --rpc-url sepolia  --private-key $PRIVATE_KEY  --broadcast
```

### Withdraw

```
cast send <FUNDME_CONTRACT_ADDRESS> "withdraw()"  --private-key <PRIVATE_KEY>
```

## Estimate gas

You can estimate how much gas things cost by running:

```
forge snapshot
```

And you'll see an output file called `.gas-snapshot`


# Formatting


To run code formatting:
```
forge fmt
```

# Frontend (Nuxt/Web) Integration

The frontend for this project already exists in the `/web` directory.

## Running the Frontend

1. Open a terminal and navigate to the `web` directory:
   ```bash
   cd web
   ```
2. Install dependencies (if you haven't already):
   ```bash
   pnpm install
   ```
3. Start the development server:
   ```bash
   pnpm run dev
   ```
4. Visit the local address shown in your terminal (usually http://localhost:3000).

## Connecting to the Smart Contracts
- Use libraries like [wagmi] in your Nuxt app to interact with your deployed contracts.
- You may want to store contract addresses and ABIs in the frontend directory for easy access.

## Dependencies
- The backend (Foundry) and frontend (Nuxt) manage their dependencies separately. Use `npm` or `yarn` in `web/`, and Foundry tools in the root.

Document any additional frontend setup or environment variables in this README as needed.

# Thank you!
