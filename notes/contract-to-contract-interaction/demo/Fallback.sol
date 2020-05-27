// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract Bank {
    mapping(address=>uint) public balances;
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
    function () external payable {}
}

contract User {
    function deposit(address payable bank) public payable {
        (bool success, ) = bank.call.value(msg.value)(abi.encodeWithSignature("deposit()"));
        require(success);
    }
    
    function badDeposit(address payable bank) public payable {
        (bool success, ) = bank.call.value(msg.value)(abi.encodeWithSignature("Deposit()"));
        require(success);
    }
}