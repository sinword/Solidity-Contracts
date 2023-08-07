// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract PiggyBank {
    address public owner;
    event Create(address owner, uint256 value);
    event Receive(address indexed sender, uint256 value);
    event Withdraw(address owner, uint256 value);
    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can call this function");
        _; 
    }
    constructor() payable {
        owner = msg.sender;
        emit Create(owner, msg.value);
    }
    receive() payable external {
        emit Receive(msg.sender, msg.value);
    }
    function withdraw() onlyOwner external {
        address payable Receiver = payable(msg.sender);
        uint256 value = address(this).balance;
        Receiver.transfer(value);
        emit Withdraw(Receiver, value);
    }
}