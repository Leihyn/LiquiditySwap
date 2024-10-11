# LockStaking and Token Contracts

This repository contains two primary smart contracts:

1. Token.sol: A basic ERC20 token contract that is used for staking and rewards.
2. LockStaking.sol: A staking contract that allows users to lock their tokens for a specific duration to earn rewards.

## Features

### Token.sol

1. ERC20 Standard: A standard ERC20 token that can be used for staking and as a reward token.
2. Minting: The token contract mints a fixed supply of tokens to the deployer (owner) at the time of deployment.

### LockStaking.sol

1. Staking: Users can stake tokens and start earning rewards over time.
2. Lock Period: Staked tokens are locked for a specific duration, and users can only withdraw or claim rewards after the lock period has elapsed.
3. Rewards Distribution: Users earn rewards based on the amount staked and the duration of their stake.
4. Withdraw: After the lock period, users can withdraw their staked tokens.
5. Claim Rewards: Users can claim their earned rewards after the lock period.

---

## Contracts Overview

### 1. Token.sol

The Token.sol contract is a simple ERC20 token contract that implements the standard ERC20 functionalities and mints a fixed supply of tokens to the deployer upon deployment.

- _owner: The address of the token owner (deployer).
- _maxSupply: The maximum supply of tokens that are minted when the contract is deployed.

### 2. LockStaking.sol

The LockStaking.sol contract allows users to stake tokens and earn rewards over time. However, staked tokens are locked for a specified duration, and users can only withdraw tokens or claim rewards after the lock period.

- s_stakingToken: The ERC20 token that users stake.
- s_rewardToken: The ERC20 token that users receive as rewards.
- s_lockDuration: The lock duration for staked tokens, during which withdrawals and reward claims are disabled.

#### Key Features

- Locking Period: Users must wait until the lock period ends to withdraw or claim rewards.
- Earned Rewards: Users accumulate rewards based on the staked amount and the duration of staking.
- Withdrawal and Claim: Tokens can only be withdrawn and rewards claimed after the lock duration has passed.

---

## How to Deploy

### Deployment Steps

1. Token Deployment: Deploy the `Token` contract with the total supply, which will be minted to the deployer's address.
2. Staking Deployment: Deploy the `LockStaking` contract, specifying the staking token, reward token, and the lock duration.

### Deploy Script

A deployment script can be used to automate the process of deploying both the `Token` and `LockStaking` contracts.

---

## License

This project is licensed under the MIT License.

