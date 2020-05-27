// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/* A demo contract for TimeLock
* Run the test as follows:
* 1) create MyToken with account A
* 2) create TokenTimelock(MyToken's contract address, account C, <blocktimestamp+200>) with account B
* 3) run MyToken.sendToken(TokenTimelock's contract address, 100) with account A
* 4) check releasetime
* 5) run TokenTimelock.release()
* 6) check MyToken.balances(account C)
*/

contract MyToken {
    mapping (address => uint) public balances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    constructor() public {
        balances[tx.origin] = 10000;
    }

    function sendToken(address receiver, uint amount) public returns(bool sufficient) {
        if (balances[msg.sender] < amount) return false;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Transfer(msg.sender, receiver, amount);
        return true;
    }
}

contract TokenTimelock {
    // MyToken basic token contract being held
    MyToken private _token;
    
    // beneficiary of tokens after they are released
    address private _beneficiary;

    // timestamp when token release is enabled
    uint256 private _releaseTime;

    constructor (MyToken token, address beneficiary, uint256 releaseTime) public {
        // solhint-disable-next-line not-rely-on-time
        require(releaseTime > block.timestamp, "TokenTimelock: release time is before current time");
        _token = token;
        _beneficiary = beneficiary;
        _releaseTime = releaseTime;
    }

    /**
     * @return the token being held.
     */
    function token() public view returns (MyToken) {
        return _token;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public virtual {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= _releaseTime, "TokenTimelock: current time is before release time");

        uint256 amount = _token.balances(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        _token.sendToken(_beneficiary, amount);
    }
}