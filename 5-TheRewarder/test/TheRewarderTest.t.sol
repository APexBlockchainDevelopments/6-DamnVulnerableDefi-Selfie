// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {AccountingToken} from "../src/AccountingToken.sol";
import {DamnValuableToken} from "../src/DamnValuableToken.sol";
import {FlashLoanerPool} from "../src/FlashLoanerPool.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {TheRewarderPool} from "../src/TheRewarderPool.sol";

contract SideEntranceLenderTest is Test {

    AccountingToken accountingToken;  //deployed
    DamnValuableToken dvt;
    FlashLoanerPool flashLoanerPool;  //deployed
    RewardToken rewardToken;
    TheRewarderPool rewarderPool;

    address admin = makeAddr("admin");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");
    address david = makeAddr("david");

    address[] users = [alice, bob, charlie, david];


    uint256 constant TOKENS_IN_LENDER_POOL = 1000000e18;
    uint256 constant USER_DEPOSIT_AMOUNT = 100e18;

    function setUp() external {
        vm.startPrank(admin);
        dvt = new DamnValuableToken();
        flashLoanerPool = new FlashLoanerPool(address(accountingToken));
        dvt.transfer(address(flashLoanerPool), TOKENS_IN_LENDER_POOL);

        rewarderPool = new TheRewarderPool(address(accountingToken));
        address rewardTokenAddress = rewarderPool.rewardToken.address;
        rewardToken = RewardToken(rewardTokenAddress);
        address accountingTokenAddress = rewarderPool.accountingToken.address;
        accountingToken = AccountingToken(accountingTokenAddress);

        assertEq(accountingToken.owner(), address(rewarderPool));
        bool accountingTokenInfoResult = accountingToken.hasAllRoles(address(rewarderPool), accountingToken.MINTER_ROLE() | accountingToken.SNAPSHOT_ROLE() | accountingToken.BURNER_ROLE());
        assertTrue(accountingTokenInfoResult);

        assertEq(rewardToken.owner(), address(rewarderPool));
        bool rewardTokenInfoResult = rewardToken.hasAllRoles(address(rewarderPool), rewardToken.MINTER_ROLE());
        assertTrue(rewardTokenInfoResult);
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

        assertEq(accountingToken.totalSupply(), users.length * USER_DEPOSIT_AMOUNT);
        assertEq(rewardToken.totalSupply(), 0);


        ///cosnoel log block.timestamp
        //wrap
        //then log the timestam9p again
    }

}