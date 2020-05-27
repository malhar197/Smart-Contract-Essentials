// SPDX-License-Identifier: MIT

pragma solidity ^ 0.6.0;

contract Bank {
    function getBalance() public view returns (uint) {return address(this).balance;}
    receive () external payable { revert(); }
    function kill(address payable target) public {
        selfdestruct(target);
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
    function getBalance() public view returns (uint) { 
        return address(this).balance; 
    }
}