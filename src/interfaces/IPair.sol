// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IPair {
    function swap(address _tokenIn, uint _amountIn) external returns (uint amountOut);
    function addLiquidity(uint _amountIn0, uint amountIn1) external returns (uint shares);
    function removeLiquidity(uint shares) external returns (uint amountOut0, uint amountOut1);
}