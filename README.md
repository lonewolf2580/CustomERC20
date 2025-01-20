# NFT Marketplace Smart Contract

This is a decentralized NFT Marketplace built using Solidity, Hardhat, and OpenZeppelin libraries. It allows users to mint, list, buy, and auction NFTs. Additionally, it supports royalties for creators and a marketplace fee.

## Features

- **Mint NFTs**: Mint unique NFTs with custom metadata and set initial prices.
- **List & Delist NFTs**: List NFTs for sale and remove them from the marketplace.
- **Buy NFTs**: Purchase NFTs from the marketplace.
- **Auction NFTs**: Start an auction, place bids, and end auctions with the highest bidder winning.
- **Royalties**: NFT creators can set and collect royalties from sales.
- **Marketplace Fee**: A small fee is charged on each transaction.

## Installation

### Requirements

- Node.js (v16.x or higher)
- Hardhat
- OpenZeppelin Contracts

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/lonewolf2580/nft-marketplace.git
   cd nft-marketplace

2. npm install


### 3. **ignition/modules/Lock.js**

Since you’re using Hardhat, this file isn't directly relevant to smart contracts but can be part of your modular design in the project. Below is a basic structure for `Lock.js`, which can help with custom deployments or contract interaction.

```javascript
// ignition/modules/Lock.js
const { ethers } = require("hardhat");

async function lockContract(contract, address) {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const contractInstance = await ethers.getContractAt("Marketplace", contract);

    console.log("Locking contract for address:", address);

    // Example: Add logic to lock a function or deploy a modifier
    await contractInstance.updateMarketplaceFee(0); // Locking the fee
    console.log("Contract locked.");
}

module.exports = { lockContract };
