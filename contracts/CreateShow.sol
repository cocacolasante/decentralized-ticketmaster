// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "./TicketsERC1155.sol";

contract CreateShow{
    address payable public admin;

    uint public showCount;

    mapping(uint=>Show) public allShows;
    mapping(uint => DegenTickets) public allContracts;

    struct Show{
        address band;
        address venue;
        address ticketContract;
    }

    event ShowCreated(address band, address venue, address ticketContract);

    constructor(){
        admin = payable(msg.sender);
    }

    function createNewShowTickets(
            string memory tokenUri,
            uint ticketPrice,
            uint bandPercentage,
            address bandAddress,
            address venueAddress,
            uint maxTickets 
        ) public {

            showCount++;


            DegenTickets newShowTickets = new DegenTickets(tokenUri, ticketPrice, bandPercentage, bandAddress, venueAddress, maxTickets);
            allContracts[showCount] = newShowTickets;

            Show memory newShow = Show(bandAddress, venueAddress, address(newShowTickets));
            newShowTickets.changeAdmin(msg.sender);

            allShows[showCount] = newShow;

            emit ShowCreated(bandAddress, venueAddress, address(newShowTickets));

        }
    
}