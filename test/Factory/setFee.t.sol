// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import { FactoryTest } from "./FactorySetup.t.sol";
import { Pair } from "../../src/Pair.sol";

contract FeeTest is FactoryTest {
    function testSetFeeAddress() public {
        address feeAddr = vm.addr(4);

        vm.startPrank(alice);
        factory.setFeeAddress(feeAddr);
        assertEq(factory.feeAddress(), feeAddr);
    }
}