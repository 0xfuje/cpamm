// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import { PairTest } from "./PairSetup.t.sol";

/// @title addLiquidity and removeLiquidity tests

contract LiquidityTest is PairTest {
    function testAddWhaleLiquidity() public {
        PairTest._addLiquidity(whale, 100, 200_000);

        assertEq(WETH.balanceOf(address(amm)), 100 * 1e18);
        assertEq(DAI.balanceOf(address(amm)), 200_000 * 1e18);
        assertEq(amm.reserve0(), WETH.balanceOf(address(amm)));
        assertEq(amm.reserve1(), DAI.balanceOf(address(amm)));

        assertEq(amm.totalShares(), 20_000_000 * 1e36);
        assertEq(amm.sharesOf(whale) / 1e36, 20_000_000);
    }

    function testAddLiquidity() public {
        PairTest._addLiquidity(whale, 100, 200_000);

        vm.startPrank(bella);
        WETH.approve(address(amm), 1 * 1e18);
        DAI.approve(address(amm), 2000 * 1e18);
        amm.addLiquidity(
            1 * 1e18,
            2000 * 1e18
        );
        assertEq(amm.reserve0(), 101 * 1e18);
        assertEq(amm.reserve1(), 202_000 * 1e18);
        
        assertEq(amm.totalShares(), 20_200_000 * 1e36);
        assertEq(amm.sharesOf(bella), 200_000 * 1e36);
    }

    function testRemoveLiquidity() public {
        PairTest._addLiquidity(whale, 100, 200_000);
        PairTest._addLiquidity(bella, 1, 2000);
        
        vm.startPrank(bella);
        amm.removeLiquidity(200_000 * 1e36);

        assertEq(amm.sharesOf(bella), 0);
        assertEq(WETH.balanceOf(bella), 1 * 1e18);
        assertEq(DAI.balanceOf(bella), 2000 * 1e18);
    }
}