// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

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
}