// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/* A demo contract for Crowd Sale
 * Run the test as follow:
 * 1) create MyCoin with account A
 * 2) create GBCCrowdSale(1, account B, MyCoin's contract address) with account C
 * 3) run MyCoin.sendCoin(GBCCrowdsale's contract address, 100) with account A
 * 4) run GBCCrowdSale.buyCoin(account D) with 40 wei and account C
 * 5) check GBCCrowdSale.getCoinBalance(GBCCrowdSale), GBCCrowdSale.getCoinBalance(account D)
 * 6) check balance of account B 
 */

contract MyCoin {
    mapping (address => uint) public balances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    constructor() public {
        balances[tx.origin] = 10000;
    }

    function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
        if (balances[msg.sender] < amount) return false;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Transfer(msg.sender, receiver, amount);
        return true;
    }
}

contract GBCCrowdSale {
    
    uint256 public _rate;
    address payable public _wallet;
    uint256 public _weiRaised;
    MyCoin _coin;

    constructor(uint256 rate, address payable wallet, MyCoin coin) public{
        require(rate > 0, "GBCCrowdSale : rate is 0");
        require(wallet != address(0), "GBCCrowdSale : wallet is the zero address");
        _rate = rate;
        _wallet = wallet;
        _coin = coin;
    }
    
    receive() external payable{
        buyCoin(msg.sender);
    }
    
    function buyCoin(address beneficiary) public payable {
        require(msg.value != 0 , "GBCCrowdSale : value is 0 ETH");
        require(beneficiary != address(0), "GBCCrowdSale : beneficiary address is 0");
        uint256 weiAmount = msg.value;
        uint256 coins = _getCoinsCreated(weiAmount);
        _weiRaised = _weiRaised + weiAmount;
        bool success = _processPurchase(beneficiary,coins);
        require(success,"The coin purchase is unsuccessful");
        emit CoinPurchased(msg.sender, weiAmount, coins);
        _forwardFunds();
    }
    
    function _getCoinsCreated(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount * _rate;
    }
    
    function _processPurchase(address beneficiary, uint256 coins) internal returns(bool) {
        return _deliverCoins(beneficiary, coins);
    }
    
    function _deliverCoins(address beneficiary, uint256 coins) internal returns(bool) {
        bool success = _coin.sendCoin(beneficiary, coins);
        return success;
    }
    
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
    
    function getCoinBalance(address holder) public view returns(uint){
        return _coin.balances(holder);
    }
    
    event CoinPurchased(address indexed purchaser, uint256 indexed weiAmount, uint256 indexed coins);
}
