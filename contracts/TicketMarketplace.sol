// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./TicketsERC1155.sol";

import "hardhat/console.sol";


contract TicketMarketplace{
    address public admin;


    constructor(){
        admin = msg.sender;
    }

    function listTicket(uint amount, uint price, address showTicketAddress) public {
        // use address and smart contract to pull current data
    }
}
