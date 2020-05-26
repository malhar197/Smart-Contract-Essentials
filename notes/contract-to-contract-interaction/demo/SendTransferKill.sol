// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract User {
    receive () external payable {
        revert();
    }
}

contract Caller {
  constructor() public payable {}
  function doTransfer(address payable user) public {
    user.transfer(1 ether);
  }
 
  function doSend(address payable user) public returns(bool){
    (bool success) = user.send(1 ether);
    return success;
  }
 
  function kill(address payable target) public {
    selfdestruct(target);
  }
}