// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/*
* deployed at 0x33f0641Eb95F9465C67e9208Cb9ec23f5AB384EC on ropsten
* re-deployed at 0xB72c3BdbCe79fE3dD5460735B659325072e2346E on ropsten
*/

contract WETH {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8  public decimals = 18;
    
    mapping( address => uint256 ) private balances;
    mapping( address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Deposit(address indexed _from, uint256 _value);
    event Withdrawal(address indexed _to, uint256 _value);

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balances[msg.sender] = balances[msg.sender] + msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    function withdraw(uint amount) public {
        require(balances[msg.sender] >= amount, "Weth withdrawal amount exceeds balance");
        
        balances[msg.sender] -= amount;
        msg.sender.transfer(amount);
        
        emit Withdrawal(msg.sender, amount);
    }
    
    function totalSupply() external view returns (uint256) {
        return address(this).balance;
    }
    
    function balanceOf(address _owner) external view returns (uint256 balance){
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) external returns (bool success) {
        return privateTransfer(msg.sender, _to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success){
        require(allowances[_from][msg.sender] >= _value, "Weth transfer amount exceeds allowance");
        privateTransfer(_from, _to, _value);
        
        uint newAllowance = allowances[_from][_to] - _value;
        return privateApprove(_from, _to, newAllowance);
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) external view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

    function privateTransfer(address _from, address _to, uint256 _value) private returns (bool success){
        require(balances[_from] >= _value, "Weth transfer amount exceeds balance");
        require(_to != address(0), "transfer to zero address");
        
        balances[_from] -= _value;
        balances[_to] += _value;
        
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function privateApprove(address _from, address _to, uint256 _value) private returns (bool success){
        allowances[_from][_to] = _value;
        emit Approval(_from, _to, _value);
        return true;
    }
}