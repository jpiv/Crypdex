// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/interfaces/IPeripheryPayments.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';

interface IWMatic {
  function deposit() external payable;
}

struct FundManagement {
  address sender;
  bool fromInternalBalance;
  address payable recipient;
  bool toInternalBalance;
}

enum SwapKind { GIVEN_IN, GIVEN_OUT }

struct SingleSwap {
  bytes32 poolId;
  SwapKind kind;
  address assetIn;
  address assetOut;
  uint256 amount;
  bytes userData;
}

interface IBalancer {
  function swap(SingleSwap memory singleSwap,
    FundManagement memory funds,
    uint256 limit,
    uint256 deadline) external payable returns (uint256 amountCalculated);
}

contract Crypdex {
  address public constant BALANCER = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

  // TOKEN ADDRESSES
  address public constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
  address public constant USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;



  // Move to Lib
  struct AddressSet {
    address[] addrs;
    mapping(address => bool) contains;
  }

  struct UserAccount {
    // Balances of tokens held by the user
    mapping(address => uint256) balances;
    // Tokens held by the user
    AddressSet holdings;
    // Whether or not the account exists
    bool exists;
  }

  /*
    OwnerAddress: {
      balances: {
        TokenAddress: balance,
        ...
      },
      holdings: [TokenAddress, ...]
    }
  */
  mapping(address => UserAccount) private accounts;

  event ContractBalance(uint256 value);
  event WEthConverted(uint256 balance);
  event Swapped(uint256 balance);

  function deposit() external payable {
    UserAccount storage account = accounts[msg.sender];

    // Initial account setup if it does not exist
    if (!account.holdings.contains[WMATIC]) {
      // Move to Lib function
      account.holdings.addrs.push(WMATIC);
      account.holdings.contains[WMATIC] = true;
    }

    // Convert ETH to WETH
    IWMatic(WMATIC).deposit{value: msg.value}();
    account.balances[WMATIC] = IERC20(WMATIC).balanceOf(address(this));

    emit WEthConverted(account.balances[WMATIC] / 1 ether);
  }

  function purchaseFund() external payable {
    // TODO: Get fund information for swapping
    emit ContractBalance(address(this).balance);

    uint256 userWethBalance = accounts[msg.sender].balances[WMATIC];
    emit ContractBalance(userWethBalance);

    // Approve w/o Uniswap
    TransferHelper.safeApprove(WMATIC, BALANCER, userWethBalance);
    
    bytes memory userDataEncoded = abi.encode(0);
    SingleSwap memory params = SingleSwap(
      0xd208168d2a512240eb82582205d94a0710bce4e7000100000000000000000038,
      SwapKind.GIVEN_IN,
      WMATIC,
      USDC,
      userWethBalance,
      userDataEncoded
    );
    FundManagement memory fundParams = FundManagement(
      address(this),
      false,
      payable(address(this)),
      false
    );

    uint256 amountOut = IBalancer(BALANCER).swap(
      params,
      fundParams,
      0,
      block.timestamp + 3000
    );
    emit Swapped(amountOut);

    emit ContractBalance(address(this).balance);
    emit ContractBalance(IERC20(USDC).balanceOf(address(this)));
  }

  receive() external payable {}
}