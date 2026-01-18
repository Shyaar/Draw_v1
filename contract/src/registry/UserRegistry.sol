// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract UserRegistry is Ownable {
    mapping(address => bool) public isRegistered;

    event UserRegistered(address indexed user);
    event UserUnregistered(address indexed user);

    constructor() Ownable(msg.sender) {}

    function register() public {
        require(!isRegistered[msg.sender], "User already registered");
        isRegistered[msg.sender] = true;
        emit UserRegistered(msg.sender);
    }

    function unregister() public {
        require(isRegistered[msg.sender], "User not registered");
        isRegistered[msg.sender] = false;
        emit UserUnregistered(msg.sender);
    }
}
