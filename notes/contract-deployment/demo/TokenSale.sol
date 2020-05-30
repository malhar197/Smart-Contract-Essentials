// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * deployed at 0xa1Bb3f2Ab45b82CbEe9fa925744B4be39133aFa7 on ropsten
 * 
 */

interface IERC20 {
    function transferFrom(address _from,address _to,uint256 _value) external returns(bool);
}

contract TokenSale {
    IERC20 public token;
    address public wallet;
    IERC20 public weth;
    
    constructor(IERC20 _tokenForSale,address tokenWallet,IERC20 wethToReceive) public {
        require(wethToReceive != _tokenForSale,"TokenSale: tokens should be different");
        require(tokenWallet != address(0), "TokenSale: wallet cannot zero");
        require(address(_tokenForSale) != address(0), "TokenSale: token address cannot be zero");
        require(address(wethToReceive) != address(0), "TokenSale: weth address cannot be zero");
        token = _tokenForSale;
        weth = wethToReceive;
        wallet = tokenWallet;
    }
    
    function claimToken(uint amount) public{
        weth.transferFrom(msg.sender, wallet, amount);
        token.transferFrom(wallet, msg.sender, amount);
    }
}