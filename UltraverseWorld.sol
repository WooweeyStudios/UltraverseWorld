// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";



contract UltraverseCoin { 
    using SafeERC20 for IERC20;


string public name = "Ultraverse Coin";
string public symbol = "ULVRC";
uint256 public decimals = 18;
uint256 public totalSupply = 4e9;
mapping (address => uint256) public balanceOf;
mapping (address => uint256) public stakedBalance;
mapping (address => uint256) public stakingPeriods;
mapping (uint256 => string) public scheduledFunctions;

bool paused;
address owner;
address world = 0x8D9d9866934363C246AbA2d17db1a8199E350BF7;
address public BUSD = 0x8D9d9866934363C246AbA2d17db1a8199E350BF7;
address public BNB = 0x8D9d9866934363C246AbA2d17db1a8199E350BF7;
address public USDC = 0x8D9d9866934363C246AbA2d17db1a8199E350BF7;


    constructor() {
        // Initialize the balance of the contract owner
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function calculateReward(uint256 amount, uint256 duration) public pure returns (uint256) {
        // Calculate the reward based on the amount staked and the staking duration
        return amount * duration;
    }

    function updateWorld(address newWorld) public {
        // Check that the caller is the contract owner
        require(msg.sender == owner, "Only the contract owner can update the world address");
        // Set the world address to the specified new address
        world = newWorld;
    }

    function gameWorldSoil() public {
        // Check that the specified recipient address is not the zero address
        require(world != address(0), "Invalid recipient address");
        // Check that the contract has a sufficient balance to make the transfer
        require(totalSupply >= 10000, "Insufficient contract balance");
        // Mint 10,000 ULVRC and increase the total supply
        totalSupply += 10000;
        // Transfer the 10,000 ULVRC to the "world" address
        IERC20(address(this)).transfer(world, 10000);
    }

    function scheduleGameWorldSoil() public {
        // Schedule the gameWorldSoil function to run every 24 hours
        uint256 interval = 24 hours;
        scheduleGameWorldSoil(interval);
    }

    function scheduleGameWorldSoil(uint256 interval) internal {
        // Check that the interval is positive
        require(interval > 0, "Invalid interval");

        // Calculate the timestamp of the next scheduled execution of the gameWorldSoil function
        uint256 nextTimestamp = block.timestamp + interval;

        // Schedule the gameWorldSoil function to run at the specified timestamp
        schedule("gameWorldSoil", nextTimestamp);
    }

    function schedule(string memory functionName, uint256 timestamp) internal {
        scheduledFunctions[timestamp] = functionName;
    }

    function mint(address recipient, uint256 amount) public {
        // Check that the recipient is not the zero address
        require(recipient != address(0), "Invalid recipient address");
        // Check that the amount is positive
        require(amount > 0, "Invalid mint amount");
        // Increase the total supply and the balance of the recipient
        totalSupply += amount;
        balanceOf[recipient] += amount;
    }

    function pause() public {
        // Check that the caller is the contract owner
        require(msg.sender == owner, "Only the contract owner can pause or unpause the contract");
        // Set the paused state variable to true
        paused = true;
    }

    function unpause() public {
        // Check that the caller is the contract owner
        require(msg.sender == owner, "Only the contract owner can pause or unpause the contract");
        // Set the paused state variable to true
        paused = false;
    }

    function stake(uint256 amount, uint256 duration) public {
        require(!paused, "Contract is paused");
        require(amount > 0, "Stake amount must be positive");
        require(duration > 0, "Staking duration must be positive");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        // Calculate the amount of ULVRC that the user will receive as a reward
        uint256 reward = calculateReward(amount, duration);

        // Lock up the specified amount of ULVRC for the specified duration
        stakedBalance[msg.sender] += amount;
        stakingPeriods[msg.sender] = block.timestamp + duration;

        // Transfer the reward to the user's account
        IERC20(address(this)).transfer(msg.sender, reward);
    }

    function unstake() public {
        require(!paused, "Contract is paused");
        require(stakingPeriods[msg.sender] > 0, "No staked ULVRC to unstake");
        require(block.timestamp >= stakingPeriods[msg.sender], "Staking period has not yet ended");

        // Calculate the amount of ULVRC that the user staked
        uint256 amount = stakedBalance[msg.sender];

        // Unlock the staked ULVRC
        stakedBalance[msg.sender] = 0;
        stakingPeriods[msg.sender] = 0;

        // Transfer the staked ULVRC back to the user's account
        IERC20(address(this)).transfer(msg.sender, amount);
    }

    function buyUltraverseCoin(address token, uint256 amount) public payable {
        // Check that the specified token is a valid ERC20 contract
        require(IERC20(token).balanceOf(msg.sender) > 0, "Invalid ERC20 token contract");

        // Check that the caller has provided enough value to cover the cost of the ULVRC
        uint256 price = 0;
        if (token == BUSD) {
            price = amount * 500;
        } else if (token == BNB) {
            price = amount * 34;
        } else if (token == USDC) {
            price = amount * 500;
        } else {
            revert("Invalid ERC20 token");
        }
        require(msg.value >= price, "Insufficient value provided");

        // Transfer the payment to the contract owner
        IERC20(token).transferFrom(msg.sender, owner, price);

        // Issue the specified amount of ULVRC to the caller
        mint(msg.sender, amount);
    }

    function withdraw(address recipient, uint256 amount) public {
        // Check that the caller is the contract owner
        require(msg.sender == owner, "Only the contract owner can withdraw tokens");
        // Check that the recipient address is not the zero address
        require(recipient != address(0), "Invalid recipient address");
        // Check that the specified amount is positive
        require(amount > 0, "Invalid withdrawal amount");
        // Check that the contract has a sufficient balance to make the withdrawal
        require(totalSupply >= amount, "Insufficient contract balance");

        // Transfer the specified amount of ULVRC to the recipient address
        IERC20(address(this)).transfer(recipient, amount);
    }


}
