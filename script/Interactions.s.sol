// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
// Fund
// widhraw

import { Script, console } from 'forge-std/Script.sol';
import { DevOpsTools } from 'foundry-devops/src/DevOpsTools.sol';
import { FundMe } from '../src/FundMe.sol';

contract FundFundMe is Script {
  uint256 constant SEND_VALUE = 0.01 ether;

  function funFundMe(address mostRecentlyDeployed) public {
    FundMe(payable(mostRecentlyDeployed)).fund{ value: SEND_VALUE }();
    console.log('Funded FundMe with %s', SEND_VALUE);
  }

  function run() external {
    vm.startBroadcast();
    address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment('FundMe', block.chainid);
    funFundMe(mostRecentlyDeployed);
    vm.stopBroadcast();
  }
}

contract WithdrawFundMe is Script {
  function withdrawFundMe(address mostRecentlyDeployed) public {
    vm.startBroadcast();
    FundMe(payable(mostRecentlyDeployed)).withdraw();
    console.log('Withdrew %s');
    vm.stopBroadcast();
  }

  function run() external {
    vm.startBroadcast();
    address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment('FundMe', block.chainid);
    withdrawFundMe(mostRecentlyDeployed);
    vm.stopBroadcast();
  }
}
