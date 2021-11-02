// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/interfaces/IPeripheryPayments.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';

interface IWETH9 {
  function deposit() external payable;
}

contract Crypdex {
  address public constant SWAP_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
  address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

  event Balance(uint256 value);
  event WEthConverted(uint256 balance);
  event Swapped(uint256 balance);

  function swip() external payable {
    emit Balance(address(this).balance);
    IWETH9(WETH9).deposit{value: 1 ether}();
    uint256 wethBalance = IERC20(WETH9).balanceOf(address(this));

    emit WEthConverted(wethBalance);

    TransferHelper.safeApprove(WETH9, SWAP_ROUTER, wethBalance);
    // // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
    // // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
      tokenIn: WETH9,
      tokenOut: DAI,
      fee: 3000,
      recipient: address(this),
      deadline: block.timestamp + 3000,
      amountIn: 1 ether,
      amountOutMinimum: 0,
      sqrtPriceLimitX96: 0
    });

    uint256 daiAmount = ISwapRouter(SWAP_ROUTER).exactInputSingle(params);
    emit Swapped(daiAmount);
    emit Balance(address(this).balance);
    IPeripheryPayments(SWAP_ROUTER).refundETH();
    emit Balance(address(this).balance);
  }
  receive() external payable {}
}