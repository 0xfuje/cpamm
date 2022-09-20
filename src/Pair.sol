// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Constant Product Automated Market Maker

contract Pair {
    address public factory;

    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint public reserve0;
    uint public reserve1;

    uint public totalShares;
    mapping(address => uint) public sharesOf;

    event MintShares(address indexed to, uint shares);
    event BurnShares(address indexed from, uint shares);
    event SyncReserves(uint reserve0, uint reserve1);
    event Swap(address indexed sender, uint amountIn, uint amountOut,
        address tokenIn, address tokenOut);
    
    error InvalidTokenAddress();
    error IncorrectLiquidityRatio();
    error ZeroAmountIn();
    error ZeroShares();
    error ZeroAmountOut(uint amountOut0, uint amountOut1);

    constructor(address _factory, address _token0, address _token1) {
        factory = _factory;
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function swap(address _tokenIn, uint _amountIn)
        external returns (uint amountOut) 
    {
        if (_tokenIn != address(token0) || _tokenIn != address(token1)) {
            revert InvalidTokenAddress();
        }
        if (_amountIn <= 0) {
            revert ZeroAmountIn();
        } 

        // 1. find out which token is tokenIn & tokenOut 
        // and which reserve is reserveIn & reserveOut
        bool isToken0 = _tokenIn == address(token0);
        (
            IERC20 tokenIn, IERC20 tokenOut,
            uint reserveIn, uint reserveOut
        ) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        // 2. calculate token out (+ fee 0.3%)
        uint amountInFee = _amountIn / 997;
        uint amountInWithFee = _amountIn - amountInFee;

        // dy = ydx / (x + dx) 
        amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);

        // 3. transfer token out to msg.sender
        tokenOut.transfer(msg.sender, amountOut);
        // 4. transfer fee token to feeAddress
        // tokenIn.transfer(factory.feeAddress, amountInFee);

        // 5. update reserves
        _syncReserves(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );
    }

    function addLiquidity(uint _amountIn0, uint _amountIn1) 
        external returns (uint shares) 
    {
        // 1. transfer in token0 and token1
        token0.transferFrom(msg.sender, address(this), _amountIn0);
        token1.transferFrom(msg.sender, address(this), _amountIn1);

        // 2. require correct ratio of liquidity in if one of the reserve is not empty
        // dy / dx = y / x =
        // x * dy = y * dx
        if (reserve0 > 0 || reserve1 > 0) {
            if (reserve0 * _amountIn1 != reserve1 * _amountIn0) {
                revert IncorrectLiquidityRatio();
            }
        }

        // 3. calculate shares
        // f(x, y) = value of liquidity = sqrt(xy)
        if (totalShares == 0) {
            shares = _sqrt(_amountIn0 * _amountIn1);
        } else {
            // s = dx / x * Ts = dx = 
            // s = dy / y * Ts = 
            // dx * Ts / x
            // get whichever calc is less
            shares = _min(
                (_amountIn0 * totalShares) / reserve0,
                (_amountIn1 * totalShares) / reserve1
            );
        }
        // 4. mint shares
        if (shares <= 0) {
            revert ZeroShares();
        }
        _mintShares(msg.sender, shares);

        // 5. update reserves
        _syncReserves(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );
    }

    function removeLiquidity(uint _shares) 
        external returns (uint amountOut0, uint amountOut1)
    {
        // calc amount0 and amount1 to withdraw
        // dx = s / Ts * x = s * x / Ts
        // dy = s / Ts * y = s * y / Ts
        uint balToken0 = token0.balanceOf(address(this));
        uint balToken1 = token1.balanceOf(address(this));

        amountOut0 = (_shares * balToken0) / totalShares;
        amountOut1 = (_shares * balToken1) / totalShares;
        if (amountOut0 <= 0 && amountOut1 <= 0) {
            revert ZeroAmountOut(amountOut0, amountOut1);
        }
        
        // burn shares 
        _burnShares(msg.sender, _shares);

        // synchronize reserves
        _syncReserves(
            balToken0 - amountOut0,
            balToken1 - amountOut1
        );

        // transfer tokens to msg.sender
        token0.transfer(msg.sender, amountOut0);
        token1.transfer(msg.sender, amountOut1);
    }

    function _mintShares(address _to, uint _amount) private {
        sharesOf[_to] += _amount;
        totalShares += _amount;
    }

    function _burnShares(address _from, uint _amount) private {
        sharesOf[_from] -= _amount;
        totalShares -= _amount;
    }

    function _syncReserves(uint _reserve0, uint _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function _sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while(x > z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }
}