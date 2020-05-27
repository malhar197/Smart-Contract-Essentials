// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract Master {
   
    function doStuff() public pure returns (uint) {
        return 6;
    }
    
    function destroy(address payable recipient) public {
        selfdestruct(recipient);
    }
}

contract Child {
    address public master;
    address payable public owner;
    
    constructor(address masterAddress) public {
        master = masterAddress; 
        owner = msg.sender;
    }
    
    function doStuff() public view returns(uint){
        (bool success, bytes memory ret) = 
        master.staticcall(abi.encodeWithSignature("doStuff()"));
        
        require(success, "doStuff failed");
        return( abi.decode(ret, (uint)));
    }
    
    function commitSuicide() public {
        (bool success, ) = 
        master.delegatecall(abi.encodeWithSignature("destroy(address)", owner));
        require(success, "failed to suicide");
    }
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    function() external payable {}
}


contract KillMaster{
    address master;
    address owner;
    
    constructor(address masterAddress) public {
        master = masterAddress;
        owner = msg.sender;
    }
    
    function doKill() public {
        (bool success,) = master.call(abi.encodeWithSignature("destroy(address)", owner));
        require(success, "failed to kill master");
    }
}