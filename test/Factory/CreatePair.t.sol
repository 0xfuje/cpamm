// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { FactoryTest } from "./FactorySetup.t.sol";
import { Pair } from "../../src/Pair.sol";

contract CreatePair is FactoryTest {
    event CreatePair(address indexed token0, address indexed token1, address pair,  uint lenght);

    function testCreatePair() public {
        vm.startPrank(bella);
        address pair = factory.createPair(address(WETH), address(DAI));
        address pairCheck = factory.getPair(address(WETH), address(DAI));

        assertEq(pair, pairCheck);
    }

    function testCreatePairAddLiquidity() public {
        vm.startPrank(chloe);
        // DAI / WETH
        address pair = factory.createPair(address(WETH), address(DAI));
        
        WETH.approve(pair, 1* 1e18);
        DAI.approve(pair, 1000 * 1e18);
        Pair(pair).addLiquidity(1000 * 1e18, 1 * 1e18);

        assertEq(address(Pair(pair).token0()), DAI_ADDRESS);
        assertEq(address(Pair(pair).token1()), WETH_ADDRESS);

        assertEq(DAI.balanceOf(pair), 1000 * 1e18);
        assertEq(WETH.balanceOf(pair), 1 * 1e18);
    }
}