# Uri Moa Wallet On-chain Setup

The frontend is ready for real wallet transactions. Deploy the contracts, then fill `ONCHAIN_CONFIG` in `index.html`.

## Local setup

```bash
npm install
copy .env.example .env
```

Edit `.env`:

```bash
DEPLOYER_PRIVATE_KEY=0xYOUR_PRIVATE_KEY_WITH_TEST_ONLY_FUNDS
```

Make sure this wallet has GIWA Sepolia test gas.

## Deploy order

Run:

```bash
npm run compile
npm run deploy:giwa
```

The script deploys:

1. `UriMoaTestUSDC`
2. `SharedVaultFactory`

It writes addresses to:

```text
deployments.giwa-sepolia.json
```

## Fill frontend config

Open `index.html` and fill:

```js
testUSDC: "0xYourUriMoaTestUSDC",
vaultFactory: "0xYourFactory"
```

## Demo transaction path

1. Connect wallet on GIWA Sepolia
2. Click `Faucet` to call `UriMoaTestUSDC.claim()`
3. Click `Deploy Vault` to call `SharedVaultFactory.createVault()`
4. Open the created Vault
5. Click `Deposit` to call `approve()` and `deposit()`
6. Click `Request Payout` to call `requestPayout()`
7. Click `Review & Approve` to call `approvePayout(0)`
8. Click `Settle & Distribute` to call `settleEqual()`

Each successful transaction is shown in the on-chain demo status panel with an explorer link.
