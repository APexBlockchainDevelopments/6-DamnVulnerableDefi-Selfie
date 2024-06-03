// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {AccountingToken} from "../src/AccountingToken.sol";
import {DamnValuableToken} from "../src/DamnValuableToken.sol";
import {FlashLoanerPool} from "../src/FlashLoanerPool.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {TheRewarderPool} from "../src/TheRewarderPool.sol";
import {AttackerContract} from "../src/AttackerContract.sol";

contract SideEntranceLenderTest is Test {

    AccountingToken accountingToken;  //deployed
    DamnValuableToken dvt;
    FlashLoanerPool flashLoanerPool;  //deployed
    RewardToken rewardToken;
    TheRewarderPool rewarderPool;
    AttackerContract attackerContract;

    address admin = makeAddr("admin");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");
    address david = makeAddr("david");

    address hacker = makeAddr("hacker");

    address[] users = [alice, bob, charlie, david];


    uint256 constant TOKENS_IN_LENDER_POOL = 1000000e18;
    uint256 constant USER_DEPOSIT_AMOUNT = 100e18;

    function setUp() external {
        vm.startPrank(admin);
        dvt = new DamnValuableToken();
        flashLoanerPool = new FlashLoanerPool(address(dvt));
        dvt.transfer(address(flashLoanerPool), TOKENS_IN_LENDER_POOL);

        rewarderPool = new TheRewarderPool(address(accountingToken));
        address rewardTokenAddress = rewarderPool.rewardToken.address;
        rewardToken = RewardToken(rewardTokenAddress);
        address accountingTokenAddress = rewarderPool.accountingToken.address;
        accountingToken = AccountingToken(accountingTokenAddress);
        vm.stopPrank();

        for(uint i = 0; i < users.length; i++){
            vm.startPrank(admin);
            dvt.transfer(users[i], USER_DEPOSIT_AMOUNT);
            vm.stopPrank();
            vm.startPrank(users[i]);
            dvt.approve(address(rewarderPool), USER_DEPOSIT_AMOUNT);
            rewarderPool.deposit(USER_DEPOSIT_AMOUNT);
            vm.stopPrank();
        }

    }

    function test_attack() public {
        // console.log(block.number);
        vm.warp(433000);
        vm.roll(block.number + 1);
        // console.log(block.number);
        vm.startPrank(hacker);
        attackerContract = new AttackerContract(address(flashLoanerPool), address(dvt), address(rewarderPool));
        attackerContract.flashLoan(100e18);
        uint256 test = accountingToken.balanceOf(address(attackerContract));

    }






    //need to figure out timing of this
}