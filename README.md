# Uri Moa Wallet

**Programmable Shared Wallet on GIWA**

Uri Moa is a shared fund management tool built on GIWA.  
It allows groups of people to collectively manage money with clear roles, spending limits, and on-chain approval rules.

Personal funds stay private. Shared funds follow transparent, enforceable rules.

## Key Features

- Create shared vaults with customizable rules
- Role-based permissions (Owner / Admin / Member)
- Daily spending limits & large expense approval
- On-chain approval flow to prevent single-person control
- Clear separation between personal wallet and shared vaults
- Designed for future embedding into GIWA Wallet

## Live Demo

- Frontend: (请替换成你的 Vercel 链接)
- Network: GIWA Sepolia (Chain ID: 91342)

## Deployed Contracts (GIWA Sepolia)

| Contract              | Address                                      |
|-----------------------|----------------------------------------------|
| UriMoaTestUSDC        | `0xb999CdA0Da5D2534F8e6d020557D3bb40adB6F66` |
| SharedVaultFactory    | `0x32DE7f4872d666eDF6042439C37b275bEB27bc28` |

## Tech Stack

- Smart Contracts: Solidity + Hardhat
- Frontend: Static HTML + JavaScript (on-chain interaction)
- Network: GIWA Sepolia

## How to Run Locally

1. Clone the repository
2. Open `index.html` directly, or deploy to Vercel
3. Connect wallet to GIWA Sepolia
4. Use the Faucet to get test tokens

## Project Structure

- `contracts/` — Smart contract source code
- `scripts/` — Deployment scripts
- `index.html` — Frontend demo
- `ONCHAIN_SETUP.md` — On-chain interaction guide
- `deployments.giwa-sepolia.json` — Deployment records

## Team

**Sora Unit**  
A two-person team of Chinese builders based in Japan.

## License

MIT
