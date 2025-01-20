# Custom ERC20 Token Project

This project implements a custom ERC-20 token with additional features such as staking rewards and an automated burning mechanism. The contract is written in Solidity and utilizes the OpenZeppelin library for secure and efficient token functionality.

---

## Features

1. **Burn Mechanism**:
   - A percentage of each transfer is burned, reducing the total token supply over time.

2. **Staking Rewards**:
   - Users can stake tokens and earn rewards based on the staking duration.

3. **Adjustable Rates**:
   - The owner can modify the burn rate and staking reward rate, with limits to ensure fairness.

4. **Transparency**:
   - Events are emitted for key actions such as token burns, stakes, and unstakes, ensuring transparency.

---

## Constructor Parameters

| Parameter      | Description                                   | Constraints                          |
|----------------|-----------------------------------------------|--------------------------------------|
| `name`         | Token name (e.g., "MyToken").                 | Must be a string.                   |
| `symbol`       | Token symbol (e.g., "MTK").                  | Must be a string.                   |
| `initialSupply`| Initial token supply.                        | Expressed as a `uint256`.           |
| `_burnRate`    | Burn rate per transfer in basis points.       | Max value: 1000 (10%).              |
| `_rewardRate`  | Staking reward rate in basis points annually. | Max value: 1000 (10%).              |

---
...

## Installation

1. Clone the repository:
   ```shell
   git clone https://github.com/lonewolf2580/CustomERC20Token.git
   cd CustomERC20Token

2. npm install

3. Update Constructor parameters in ignition/modules/Lock.js

4. npx hardhat compile

5. npx hardhat ignition deploy ./ignition/modules/Lock.js --network <network>

## Example Interraction with Ethers.js

```javascript
const contract = await ethers.getContractAt("CustomERC20Token", "DEPLOYED_CONTRACT_ADDRESS");

console.log(await contract.name()); // MyToken
console.log(await contract.symbol()); // MTK
console.log(await contract.burnRate()); // Burn rate in basis points
console.log(await contract.rewardRate()); // Reward rate in basis points
```

