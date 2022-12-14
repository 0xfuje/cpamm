// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import { PairTest } from "./PairSetup.t.sol";

contract SwapTest is PairTest {
    function testSwap() public {
        PairTest._addLiquidity(whale, 100, 200_000);

        vm.startPrank(alice);
        DAI.approve(address(pair), 2000 * 1e18);
        pair.swap(address(DAI), 2000 * 1e18);

        assertGt(WETH.balanceOf(alice), 9 * 1e17); // greater than 0.9 WETH
        assertLt(WETH.balanceOf(alice), 1 * 1e18); // less than 1 WETH
        emit log_uint(WETH.balanceOf(alice));

        assertGt(DAI.balanceOf(factory.feeAddress()), 2 * 1e18);
        assertLt(DAI.balanceOf(factory.feeAddress()), 3 * 1e18);
        emit log_uint(DAI.balanceOf(factory.feeAddress()));
    }

    function testImpermanentLoss() public {
        PairTest._addLiquidity(bella, 1, 2000);

        vm.startPrank(alice);
        DAI.approve(address(pair), 1000 * 1e18);
        pair.swap(address(DAI), 1000 * 1e18);
        vm.stopPrank();

        vm.startPrank(bella);
        assertEq(pair.sharesOf(bella), 2000 * 1e36);
        pair.removeLiquidity(2000 * 1e36);
        vm.stopPrank();

        assertGt(DAI.balanceOf(bella), 2000 * 1e18);
        assertLt(WETH.balanceOf(bella), 1 * 1e18);

        emit log_uint(DAI.balanceOf(bella)); // 3000 DAI
        emit log_uint(WETH.balanceOf(bella)); // 0.66 ETH

        // if ETH price would gone up by 5x from $2000 to $10000
        // price of supplied liquidity would be $3000 (DAI) + $6600 (ETH) = $9900
        // if the liquidity provider would have hold the initial assets
        // aka 1 eth and 2000 dai than he would have $2000 (DAI) + $10000 (ETH) = $12000
    }
}