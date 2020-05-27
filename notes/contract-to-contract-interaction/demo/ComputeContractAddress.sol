// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract ComputeContractAddress {
    function getAddr(address addr, byte nonce) public pure returns(address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(byte(0xd6), byte(0x94), addr, byte(nonce))))));
    }
}
