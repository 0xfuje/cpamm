// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import { PairTest } from "./PairSetup.t.sol";

/// @title addLiquidity and removeLiquidity tests

contract LiquidityTest is PairTest {
    function testAddWhaleLiquidity() public {
        PairTest._addLiquidity(whale, 100, 200_000);

        assertEq(WETH.balanceOf(address(pair)), 100 * 1e18);
        assertEq(DAI.balanceOf(address(pair)), 200_000 * 1e18);
        assertEq(pair.reserve0(), WETH.balanceOf(address(pair)));
        assertEq(pair.reserve1(), DAI.balanceOf(address(pair)));

        assertEq(pair.totalShares(), 20_000_000 * 1e36);
        assertEq(pair.sharesOf(whale) / 1e36, 20_000_000);
    }

    function testAddLiquidity() public {
        PairTest._addLiquidity(whale, 100, 200_000);

        vm.startPrank(bella);
        WETH.approve(address(pair), 1 * 1e18);
        DAI.approve(address(pair), 2000 * 1e18);
        pair.addLiquidity(
            1 * 1e18,
            2000 * 1e18
        );
        assertEq(pair.reserve0(), 101 * 1e18);
        assertEq(pair.reserve1(), 202_000 * 1e18);
        
        assertEq(pair.totalShares(), 20_200_000 * 1e36);
        assertEq(pair.sharesOf(bella), 200_000 * 1e36);
    }

    function testRemoveLiquidity() public {
        PairTest._addLiquidity(whale, 100, 200_000);
        PairTest._addLiquidity(bella, 1, 2000);
        
        vm.startPrank(bella);
        pair.removeLiquidity(200_000 * 1e36);

        assertEq(pair.sharesOf(bella), 0);
        assertEq(WETH.balanceOf(bella), 1 * 1e18);
        assertEq(DAI.balanceOf(bella), 2000 * 1e18);
    }
}