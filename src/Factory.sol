// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Pair } from "./Pair.sol";

contract Factory {
    address public owner;
    address public feeAddress;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    error NotOwner();
    error IdenticalTokenAddress();
    error PairAlreadyExists();

    event CreatePair(address pair, address indexed token0, address indexed token1, uint lenght);

    constructor() {
        owner = msg.sender;
    }

    function setFeeAddress(address _feeAddress) public {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        feeAddress = _feeAddress;
    }

    function createPair(address tokenA, address tokenB) 
        external returns (address pair) 
    {
        if (tokenA == tokenB) {
            revert IdenticalTokenAddress();
        }
        // 1. sort order of tokens
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        if (getPair[token0][token1] != address(0)) {
            revert PairAlreadyExists();
        }
        // 2. generate salt from hash of token0 & token1
        bytes memory bytecode = type(Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));

        // 3. create pair contract
        new Pair{salt: salt}(address(this), token0, token1);

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;

        allPairs.push(pair);
        emit CreatePair(pair, token0, token1, allPairs.length);
    }
}