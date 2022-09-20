// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import { Pair } from "../../src/Pair.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PairTest is Test {
    Pair public pair;
    uint256 mainnetFork;
    string mainnetUrl;

    address alice = vm.addr(1);
    address bella = vm.addr(2);
    address whale = vm.addr(3);
    
    IERC20 WETH;
    IERC20 DAI;
    address constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    function setUp() public {
        mainnetUrl = vm.envString('MAINNET_URL');
        mainnetFork = vm.createSelectFork(mainnetUrl);

        WETH = IERC20(WETH_ADDRESS);
        DAI = IERC20(DAI_ADDRESS);
        pair = new Pair(address(0x0), WETH_ADDRESS, DAI_ADDRESS);

        deal(DAI_ADDRESS, alice, 2000 * 1e18);
        deal(WETH_ADDRESS, bella, 1 * 1e18);
        deal(DAI_ADDRESS, bella, 2000 * 1e18);
        deal(WETH_ADDRESS, whale, 100 * 1e18);
        deal(DAI_ADDRESS, whale, 200_000 * 1e18);
    }

    function _addLiquidity(
        address depositor,
        uint256 weth_amount,
        uint256 dai_amount
    ) internal {
        vm.startPrank(depositor);
        WETH.approve(address(pair), weth_amount * 1e18);
        DAI.approve(address(pair), dai_amount * 1e18);
        pair.addLiquidity(
            weth_amount * 1e18,
            dai_amount * 1e18
        );
        vm.stopPrank();
    }
}
