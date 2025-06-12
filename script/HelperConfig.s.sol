// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// 1. Deploy mocks when we are on local anvil chain
// 2. Keep Track of contract aaddres across different chains
// e.g Speolia ETH/USD, Mainnet ETH/USD

import { Script } from 'forge-std/Script.sol';
import { MockV3Aggregator } from '../test/mocks/MockV3Aggregator.sol';

contract HelperConfig is Script {
  // If localchain: deploy mocks, otherwise grap the existing from live network
  NetworkConfig public activeNetworkConfig;
  uint8 public constant DECIMALS = 8;
  int256 public constant INITIAL_PRICE = 2000e8;

  struct NetworkConfig {
    address priceFeed; //ETH/USD price feed address
  }

  constructor() {
    if (block.chainid == 11155111) {
      activeNetworkConfig = getSepoliaEthConfig();
    } else if (block.chainid == 1) {
      activeNetworkConfig = getMainnetEthConfig();
    } else {
      activeNetworkConfig = getOrCreateAnvilConfig();
    }
  }

  function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
    NetworkConfig memory sepoliaConfig = NetworkConfig({ priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 });
    return sepoliaConfig;
  }

  function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
    NetworkConfig memory ethConfig = NetworkConfig({ priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 });
    return ethConfig;
  }

  function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
    //1. Deploy the mocks
    //2. Deploy the mocks address
    
    // NOTE:
    // address(0) is a null address == 0x0000000000000000000000000000000000000000
    // represents a NULL address. Does't points to a contract or external account.

    // Here it verifies if pricefeed is not null (not defined).
    if (activeNetworkConfig.priceFeed != address(0)) {
      return activeNetworkConfig;
    }

    vm.startBroadcast();
    //Contract instance
    MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
    vm.stopBroadcast();

    // The instance needs to be converted to address because is
    NetworkConfig memory anvilConfig = NetworkConfig({ priceFeed: address(mockPriceFeed) });
    return anvilConfig;
  }

}
