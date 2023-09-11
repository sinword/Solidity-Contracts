// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSuply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract ERC20 is IERC20 {
    address _owner;
    uint256 _totalSupply;
    mapping(address => uint256) _balance; 
    mapping(address => mapping(address => uint256)) _allowance;
    string _name;
    string _symbol;

    modifier onlyOwner() {
        require(msg.sender == _owner, "ERROR: only owner can access this fucntion");
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        _owner = msg.sender;
        _name = name_;
        _symbol = symbol_;
        _balance[msg.sender] = 10000;
        _totalSupply = 10000;
    }

    function mint(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "ERROR, mint to void");
        _totalSupply += amount;
        _balance[account] += amount;
        // Transfer from void to account
        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "ERROR, burn form void");
        _totalSupply -= amount;
        uint accountBalance = _balance[account];
        require(accountBalance >= amount, "ERROR: insufficient balance to burn");
        _balance[account] = accountBalance - amount;
        // Transfer form account to void
        emit Transfer(account, address(0), amount);
    }



    function name() public view returns (string memory) {
        return _name;   
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSuply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balance[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowance[owner][spender];
    }
 
    function internalTransfer(address from, address to, uint256 amount) internal {
        uint256 myBalance = _balance[from];
        require(myBalance >= amount, "Insufficient balnace");
        require(to != address(0), "Transfer to void");

        _balance[msg.sender] = myBalance - amount;
        _balance[to] = _balance[to] + amount;
        emit Transfer(msg.sender, to, amount);
    }

    function internalApprove(address owner, address spender, uint256 amount) internal {
        _allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        internalTransfer(msg.sender, to, amount);
        return true;
    } 

    function approve(address spender, uint256 amount) public returns (bool) {
        internalApprove(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 myAllowance = _allowance[from][msg.sender];
        // Check if authorized balance is adequate
        require(myAllowance >= amount, "ERROR: myAllowance < amount");
        internalApprove(from, msg.sender, myAllowance - amount);

        // Check if balance of account owner is adequate
        internalTransfer(from, to, amount);
        return true;
    }

}