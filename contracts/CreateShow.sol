// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


import "./TicketsERC1155.sol";
import "./TicketEscrow.sol";

contract CreateShow{
    address payable public admin;

    Show public FeaturedShow;

    uint public showCount;

    mapping(uint=>Show) public allShows;
    mapping(uint => DegenTickets) public allContracts;


    struct Show{
        address band;
        address venue;
        DegenTickets ticketContract; 
        TicketEscrow escrowContract;
        bool showCompleted;
        bool showCancelled;
        uint date;
    }

    event ShowCreated(address band, address venue, address ticketContract);

    event ShowCompleted(address band, address Venue, address ticketContract);

    event ShowCancelled(address band, address venue, address ticketContract);

    event ShowRescheduled(address band, address venue, address ticketContract, uint newDate);

 


    receive() external payable{}

    constructor(){
        admin = payable(msg.sender);
    }

    function createNewShowTickets(
            string memory tokenUri,
            uint ticketPrice,
            uint bandPercentage,
            address bandAddress,
            address venueAddress,
            uint maxTickets, 
            // enter date in days
            uint date
        ) public {

            showCount++;

            TicketEscrow newEscrowContract = new TicketEscrow();


            DegenTickets newShowTickets = new DegenTickets(tokenUri, ticketPrice, bandPercentage, bandAddress, venueAddress, maxTickets, address(newEscrowContract));
            allContracts[showCount] = newShowTickets;

            newEscrowContract.setTicketContract(address(newShowTickets));
            // 43200 is 24 hours after the date to ensure band plans 
            uint convertedDate = date * 24 * 60 *60 + 86400 +block.timestamp;

            Show memory newShow = Show(bandAddress, venueAddress, newShowTickets, newEscrowContract, false, false, convertedDate);

            // should i keep this contract as admin of new ticket contracts?

            allShows[showCount] = newShow;

            emit ShowCreated(bandAddress, venueAddress, address(newShowTickets));

        }


    


    function payForShow(uint showNumber) public payable {
        Show storage currentShow = allShows[showNumber];
        require(msg.sender == currentShow.venue || msg.sender == admin);
        require(block.timestamp >= currentShow.date, "show hasnt happened yet");

        currentShow.escrowContract.releaseFunds();

        currentShow.ticketContract.payBandAndVenue();

        currentShow.showCompleted = true;
        
        emit ShowCompleted(currentShow.band, currentShow.venue, address(currentShow.ticketContract) );


    }

    function cancelShow(uint showNumber) public payable {
        Show storage currentShow = allShows[showNumber];
        require(msg.sender == currentShow.venue || msg.sender == admin);

        currentShow.showCancelled = true;
        currentShow.escrowContract.releaseFunds();
        currentShow.ticketContract.sendRefund();
        currentShow.ticketContract.cancelShow();

        emit ShowCancelled(currentShow.band, currentShow.venue, address(currentShow.ticketContract));

    }

    function rescheduleShow(uint showNumber, uint newDate) public {
        Show storage currentShow = allShows[showNumber];
        require(msg.sender == currentShow.venue || msg.sender == admin);

        uint convertedDate = newDate * 24 * 60 * 60 + 86400;
        currentShow.date = convertedDate;

        emit ShowRescheduled(currentShow.band, currentShow.venue, address(currentShow.ticketContract), newDate );
    }

    


    
}
