# Uri Moa Wallet

Static frontend demo for Uri Moa Wallet with on-chain transaction hooks for GIWA Sepolia.

## Current deployed contracts

- UriMoaTestUSDC: `0xb999CdA0Da5D2534F8e6d020557D3bb40adB6F66`
- SharedVaultFactory: `0x32DE7f4872d666eDF6042439C37b275bEB27bc28`
- Network: GIWA Sepolia, Chain ID `91342`

## Deploy

Upload this folder to GitHub, then import the repository in Vercel.

- Framework Preset: Other
- Build Command: leave empty, or use `npm run build`
- Output Directory: leave empty

Do not upload `.env` or `node_modules/`. They are ignored by `.gitignore`.

## On-chain mode

The deployed GIWA Sepolia addresses are already filled in `ONCHAIN_CONFIG` inside `index.html`:

- `testUSDC`
- `vaultFactory`

See `ONCHAIN_SETUP.md` for the transaction demo flow.
