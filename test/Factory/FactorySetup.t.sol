// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import { Factory } from "../../src/Factory.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FactoryTest is Test {
    Factory public factory;
    uint256 mainnetFork;
    string mainnetUrl;

    address alice = vm.addr(1);
    address bella = vm.addr(2);
    address chloe = vm.addr(3);
    
    IERC20 WETH;
    IERC20 DAI;

    address constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    function setUp() public {
        mainnetUrl = vm.envString('MAINNET_URL');
        mainnetFork = vm.createSelectFork(mainnetUrl);

        vm.prank(alice);
        factory = new Factory();

        WETH = IERC20(WETH_ADDRESS);
        DAI = IERC20(DAI_ADDRESS);

        deal(address(WETH), chloe, 1 * 1e18);
        deal(address(DAI), chloe, 1000 * 1e18);
    }
}