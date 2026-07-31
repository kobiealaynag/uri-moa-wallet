const fs = require("fs");
const path = require("path");
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with:", deployer.address);

  const Token = await hre.ethers.getContractFactory("UriMoaTestUSDC");
  const token = await Token.deploy();
  await token.waitForDeployment();
  const tokenAddress = await token.getAddress();
  console.log("UriMoaTestUSDC:", tokenAddress);

  const Factory = await hre.ethers.getContractFactory("SharedVaultFactory");
  const factory = await Factory.deploy();
  await factory.waitForDeployment();
  const factoryAddress = await factory.getAddress();
  console.log("SharedVaultFactory:", factoryAddress);

  const out = {
    network: "GIWA Sepolia",
    chainId: 91342,
    uriMoaTestUSDC: tokenAddress,
    sharedVaultFactory: factoryAddress,
    deployedAt: new Date().toISOString()
  };

  const outPath = path.join(__dirname, "..", "deployments.giwa-sepolia.json");
  fs.writeFileSync(outPath, JSON.stringify(out, null, 2));
  console.log("Saved:", outPath);
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
