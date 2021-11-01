// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crypdex {
  uint256 private _value;

  event RecievedAmount(uint256 value);

  receive() external payable {
    emit RecievedAmount(msg.value);
  }
}