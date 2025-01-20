const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("DeployNFTMarketplace", (m) => {
  // Define parameters for the Marketplace contract
  const marketplaceFee = 500;  // 5% marketplace fee

  // Deploy the Marketplace contract (no constructor parameters needed in this case)
  const Marketplace = m.contract("Marketplace", {
    args: [],  // No constructor args needed as it's set to default values in the contract
  });

  return { Marketplace };
});
