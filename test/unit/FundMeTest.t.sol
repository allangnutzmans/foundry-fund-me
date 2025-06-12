// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Test, console } from 'forge-std/Test.sol';
import { FundMe } from '../../src/FundMe.sol';
import { DeployFundMe } from '../../script/DeployFundMe.s.sol';

contract FundMeTest is Test {
  FundMe fundMe;

  address USER = makeAddr('user'); // Add a fake user and address (cheatcode/test from forge-std only)
  uint256 constant SEND_VALUE = 0.1 ether; // 1000000000000000000
  uint256 constant STARTING_BALANCE = 10 ether;

  //setUp always runs first
  function setUp() external {
    // us -> FundMeTest -> FundMe (so acctually, FundMeTest is the owner of FundMe)
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
    vm.deal(USER, STARTING_BALANCE); //Add a balance (cheatcode/test from forge-std only)
  }

  function testMinimumDolarIsFive() public {
    assertEq(fundMe.MINIMUM_USD(), 5e18);
  }

  function testOwnerIsMsgSender() public {
    assertEq(fundMe.getOwner(), msg.sender);
  }

  function testPriceFeedVersionIsAccurate() public {
    uint256 version = fundMe.getVersion();
    assertEq(version, 4);
  }

  function testFundFailsWhithoutEnoughEth() public {
    vm.expectRevert(); // next line should revert! (like assert(this tx should revert))
    fundMe.fund(); // send 0 value
  }

  function testFundUpdatesFundedDataStructure() public {
    // PRANK sets
    vm.prank(USER); // The next tx will be sent by the USER
    fundMe.fund{ value: SEND_VALUE }();
    uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
    assertEq(amountFunded, SEND_VALUE);
  }

  function testAddsFunderToArrayOfFunders() public {
    vm.prank(USER);
    fundMe.fund{ value: SEND_VALUE }();
    address funder = fundMe.getFunder(0);
    assertEq(USER, funder);
    /*     int index = fundMe.s_funders[user];
    assertEq(user, fundMe.getFunder(index)); */
  }

  modifier funded() {
    vm.prank(USER);
    fundMe.fund{ value: SEND_VALUE }();
    _;
  }

  function testOnlyOnwerCanWithdraw() public funded {
    vm.expectRevert(); // skips vm statments, so order dont matter between the vm statments
    vm.prank(USER);
    fundMe.withdraw();
  }

  function testWithdrawWithASingleFunder() public funded {
    // Arrange
    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 staringFundMeBalance = address(fundMe).balance;

    // Act
    vm.prank(fundMe.getOwner());
    fundMe.withdraw();

    // Assert
    uint256 endingOwnerBalance = fundMe.getOwner().balance;
    uint256 endingFundMeBalance = address(fundMe).balance;

    assertEq(endingFundMeBalance, 0);
    assertEq(startingOwnerBalance + staringFundMeBalance, endingOwnerBalance);
  }

  function testWithdrawFromMultipleFunders() public funded {
    // Arrage
    uint160 numOfFunders = 10;
    uint160 startingFunderIndex = 1; //avoid sanity tests
    for (uint160 i = startingFunderIndex; i < numOfFunders; i++) {
      // hoax - sets up an address with some eth
      hoax(address(i), SEND_VALUE);
      fundMe.fund{ value: SEND_VALUE }();
    }

    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 staringFundMeBalance = address(fundMe).balance;

    // Act
    vm.startPrank(fundMe.getOwner()); // startPrank and stopPrank is just a more explicit syntax
    fundMe.withdraw();
    vm.stopPrank();

    // Assert
    assert(address(fundMe).balance == 0);
    assert(staringFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
  }

  function testWithdrawFromMultipleFundersCheaper() public funded {
    // Arrage
    uint160 numOfFunders = 10;
    uint160 startingFunderIndex = 1; //avoid sanity tests
    for (uint160 i = startingFunderIndex; i < numOfFunders; i++) {
      // hoax - sets up an address with some eth
      hoax(address(i), SEND_VALUE);
      fundMe.fund{ value: SEND_VALUE }();
    }

    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 staringFundMeBalance = address(fundMe).balance;

    // Act
    vm.startPrank(fundMe.getOwner()); // startPrank and stopPrank is just a more explicit syntax
    fundMe.cheaperWithdraw();
    vm.stopPrank();

    // Assert
    assert(address(fundMe).balance == 0);
    assert(staringFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
  }
}
