# Custom ERC20 Project

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CustomERC20Token
 * @dev An ERC-20 token with custom features: staking rewards and an automated burning mechanism.
 *
 * ## Features
 * 1. **Burn Mechanism**: A percentage of each transfer is burned, reducing the total supply over time.
 * 2. **Staking Rewards**: Users can stake tokens and earn rewards based on staking duration.
 * 3. **Adjustable Rates**: The owner can modify burn and staking reward rates within defined limits.
 * 4. **Transparency**: Events are emitted for all major actions, including burns, stakes, and unstakes.
 *
 * ## Parameters
 * - `burnRate`: The percentage of tokens burned per transaction, in basis points (1% = 100 basis points).
 * - `rewardRate`: The annual percentage yield for staking rewards, in basis points.
 *
 * ## Constructor
 * - `name`: Token name.
 * - `symbol`: Token symbol.
 * - `initialSupply`: Initial token supply, minted to the deployer's address.
 * - `_burnRate`: Initial burn rate, limited to 10% (1000 basis points).
 * - `_rewardRate`: Initial reward rate, limited to 10% (1000 basis points).
 */
contract CustomERC20Token is ERC20, Ownable {
    uint256 public burnRate; // Burn rate in basis points (1% = 100 basis points)
    uint256 public rewardRate; // Reward rate in basis points

    mapping(address => uint256) private _stakedBalances;
    mapping(address => uint256) private _stakingTimestamps;

    event Burn(address indexed from, uint256 amount);
    event Stake(address indexed staker, uint256 amount);
    event Unstake(address indexed staker, uint256 amount, uint256 rewards);

    /**
     * @dev Initializes the contract with the given parameters.
     */
    constructor(string memory name, string memory symbol, uint256 initialSupply, uint256 _burnRate, uint256 _rewardRate) ERC20(name, symbol) {
        require(_burnRate <= 1000, "Burn rate must be <= 10%");
        require(_rewardRate <= 1000, "Reward rate must be <= 10%");

        burnRate = _burnRate;
        rewardRate = _rewardRate;

        _mint(msg.sender, initialSupply * (10 ** decimals()));
    }

    /**
     * @dev Transfers tokens while applying the burn mechanism.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 burnAmount = (amount * burnRate) / 10000;
        uint256 transferAmount = amount - burnAmount;

        if (burnAmount > 0) {
            _burn(_msgSender(), burnAmount);
            emit Burn(_msgSender(), burnAmount);
        }

        return super.transfer(recipient, transferAmount);
    }

    /**
     * @dev Stakes a specified amount of tokens.
     */
    function stake(uint256 amount) external {
        require(amount > 0, "Cannot stake 0 tokens");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance to stake");

        _stakedBalances[msg.sender] += amount;
        _stakingTimestamps[msg.sender] = block.timestamp;

        _burn(msg.sender, amount);

        emit Stake(msg.sender, amount);
    }

    /**
     * @dev Unstakes all tokens and rewards the user based on the staking duration.
     */
    function unstake() external {
        uint256 stakedAmount = _stakedBalances[msg.sender];
        require(stakedAmount > 0, "No tokens to unstake");

        uint256 stakingDuration = block.timestamp - _stakingTimestamps[msg.sender];
        uint256 reward = (stakedAmount * rewardRate * stakingDuration) / (10000 * 365 days);

        _stakedBalances[msg.sender] = 0;
        _stakingTimestamps[msg.sender] = 0;

        _mint(msg.sender, stakedAmount + reward);

        emit Unstake(msg.sender, stakedAmount, reward);
    }

    /**
     * @dev Updates the burn rate. Can only be called by the owner.
     */
    function setBurnRate(uint256 newBurnRate) external onlyOwner {
        require(newBurnRate <= 1000, "Burn rate must be <= 10%");
        burnRate = newBurnRate;
    }

    /**
     * @dev Updates the reward rate. Can only be called by the owner.
     */
    function setRewardRate(uint256 newRewardRate) external onlyOwner {
        require(newRewardRate <= 1000, "Reward rate must be <= 10%");
        rewardRate = newRewardRate;
    }

    /**
     * @dev Returns the staked balance of an account.
     */
    function stakedBalance(address account) external view returns (uint256) {
        return _stakedBalances[account];
    }

    /**
     * @dev Returns the staking timestamp of an account.
     */
    function stakingTimestamp(address account) external view returns (uint256) {
        return _stakingTimestamps[account];
    }
}

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```
