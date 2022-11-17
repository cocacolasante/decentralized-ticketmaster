// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./CreateShow.sol";
import "./utils/IDegenTickets.interface.sol";

import "hardhat/console.sol";


contract TicketMarketplace{
    address public admin;

    // create a way to map tickets for sale from different shows to one address

    TixForSale[] public allTicketsForSale;

    struct TixForSale{
        address owner;
        address ticketContract;
        uint showNumber;
        uint amount;
        uint price;
        bool sold;
    }

    constructor(){
        admin = msg.sender;
    }

    function listTickets(uint amount, uint price, address ticketAddress) public {
        // use address and smart contract to pull current data
        uint senderBalance = IDegenTickets(ticketAddress).balanceOf(msg.sender, 1);
        require(senderBalance >=amount, "not enough tickets owned");


    }
}
