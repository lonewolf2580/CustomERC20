const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("DeployToken", (m) => {
  // Define constructor parameters
  const name = "MyToken";
  const symbol = "MTK";
  const initialSupply = BigInt("100000000000000000000000000"); // 100 million tokens with 18 decimal places
  const burnRate = 200; // 2% burn rate (200 basis points)
  const rewardRate = 500; // 5% reward rate (500 basis points)

  // Deploy the contract with parameters
  const CustomERC20Token = m.contract("CustomERC20Token", {
    args: [name, symbol, initialSupply, burnRate, rewardRate], // Pass parameters here
  });

  return { CustomERC20Token };
});
