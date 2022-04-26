//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract Launchpad is Context {
    using SafeERC20 for IERC20;

    uint256 private _fee;
    ISwapRouter private immutable _swapRouter; 
    address private immutable _bnbAddress;
    mapping(address => bool) private _registerMap;
    mapping(address => uint256) private _tokenBalance;


    constructor(ISwapRouter swapRouter, uint256 fee, address bnbAddress) Context(msg.sender) {
        _swapRouter = swapRouter;
        _fee = fee;
        _bnbAddress = bnbAddress;
    }

    function register(address token) external {
        _registerMap[token] = true;
    }

    function deposit(address token) external payable {
        require(_registerMap[token]);

        address sender = _msgSender();
        uint256 value = _msgValue();
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: _bnbAddress,
                tokenOut: token,
                fee: 3000,
                recipient: sender,
                deadline: block.timestamp,
                amountIn: value,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        uint256 amountOut = _swapRouter.exactInputSingle(params);

        IERC20(token).safeTransfer(sender, amountOut);
        _tokenBalance[token] += value;
    }
} 