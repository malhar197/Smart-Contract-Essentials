// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract ABIEncoding {
    function fun(bool xy) public pure returns (bytes4) {
        return (this.fun.selector);
    }
}
