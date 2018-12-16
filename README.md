# Hello DEXON
**Hello DEXON** is a simple smart contract utilizing DEXON's unbiased randomness.

## Installation
1. `git clone https://github.com/dexon-foundation/hello-dexon.git`
2. `cd hello-dexon`
3. `npm install` or `yarn`
4. (Optional) Install dexon-truffle globally `npm install -g @dexon-foundation/truffle`

## Compile
1. `npm run compile` or `dexon-truffle compile`

## Test
1. `npm install -g @dexon-foundation/ganache-cli`
2. Run local ganache server `dexon-ganache-cli`
3. `npm run test`

## Deploy contract (on DEXON testnet)
1. Copy `secret.js.sample` to `secret.js`.
2. Set the `mnemonic` in `secret.js`.
3. `npm run migrate` or `dexon-truffle migrate --network=testnet`
