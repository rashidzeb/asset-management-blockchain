// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

error Pool__NotAdmin();

contract Pool {
    event deposited(address indexed from, uint256 ammount);

    mapping(address => uint256) public addressToAmmount;

    address[] public clients;
    address public immutable i_admin;

    constructor() {
        i_admin = msg.sender;
    }

    function depositFund() public payable {
        require(msg.value >= 7e16, "You need to deposit at least 0.07 ether");
        clients.push(msg.sender);
        addressToAmmount[msg.sender] = msg.value;
    }

    function withdraw() public administrator {
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    modifier administrator() {
        if (msg.sender != i_admin) {
            revert Pool__NotAdmin();
        }
        _;
    }

    receive() external payable {
        depositFund();
    }

    fallback() external payable {
        depositFund();
    }
}
