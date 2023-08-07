// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Donation {
    address public owner;
    mapping(address => uint256) donationList;
    event Donate(address indexed sender, uint value);
    event Withdraw(address indexed owner, uint value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can accecss this function");
        _;
    }

    constructor() {
        // Set contract owner as first msg sender
        owner = msg.sender;
    }

    function donate() public payable {
        donationList[msg.sender] += msg.value;
        emit Donate(msg.sender, msg.value);
    }

    function getHistory() public view returns (uint256) {
        return donationList[msg.sender];
    }

    function getRank() public view returns (string memory) {
        if (donationList[msg.sender] > 10 ether) {
            return  "UR";
        }
        else if (donationList[msg.sender] > 5 ether) {
            return "SR";
        }
        else if (donationList[msg.sender] > 1 ether) {
            return "R";
        }
        else if (donationList[msg.sender] > 0) {
            return "N";
        }
        else {
            return "None";
        }
    }

    function withdraw() onlyOwner public {
        address payable receiver = payable(owner);
        uint value = address(this).balance;
        receiver.transfer(value);
        emit Withdraw(receiver, value);
    }   
}