// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import { AMM } from "../src/AMM.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract AMMTest is Test {
    AMM public amm;

    address alice = vm.addr(1);
    address bella = vm.addr(2);
    address whale = vm.addr(3);
    
    IERC20 WETH;
    IERC20 DAI;
    address constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    function setUp() public {

        WETH = IERC20(WETH_ADDRESS);
        DAI = IERC20(DAI_ADDRESS);
        amm = new AMM(WETH_ADDRESS, DAI_ADDRESS);

        deal(WETH_ADDRESS, alice, 1 * 1e18);
        deal(DAI_ADDRESS, alice, 2000 * 1e18);
        deal(WETH_ADDRESS, bella, 1 * 1e18);
        deal(DAI_ADDRESS, bella, 2000 * 1e18);
        deal(WETH_ADDRESS, whale, 100 * 1e18);
        deal(DAI_ADDRESS, whale, 200_000 * 1e18);
    }

    function whaleDeposit() public {
        vm.startPrank(whale);
        WETH.approve(address(amm), 100 * 1e18);
        DAI.approve(address(amm), 200_000 * 1e18);
        amm.addLiquidity(
            100 * 1e18,
            200_000 * 1e18
        );
    }
}