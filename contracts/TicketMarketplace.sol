// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./utils/IDegenTickets.interface.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import "hardhat/console.sol";


contract TicketMarketplace is ERC1155Holder{
    address public admin;

    uint public bandPercent = 10;

    // create a way to map tickets for sale from different shows to one address
    // ticket address to user address to amount of tickets
    mapping(address=>mapping(address => TixForSale)) public ticketsByShow;

    TixForSale[] public allTicketsForSale;

    struct TixForSale{
        address owner;
        address ticketContract;
        address bandAddress;
        uint amount;
        uint price;
        bool sold;
    }

    event TicketListed(address owner, address ticketAddress, uint price, uint amount);
    event TicketPurchased(address newOwner, address ticketAddress, uint price, uint amount);
    event ListingCancelled(address owner, address ticketAddress, uint amount);

    modifier onlyAdmin {
        require(msg.sender == admin, "only admin");
        _;
    }

    constructor(){
        admin = msg.sender;
    }

    function listTickets(uint amount, uint price, address ticketAddress, address bandAddress) public {
        // use address and smart contract to pull current data
        uint senderBalance = IDegenTickets(ticketAddress).balanceOf(msg.sender, 1);
        require(senderBalance >=amount, "not enough tickets owned");

        ticketsByShow[ticketAddress][msg.sender] = TixForSale(msg.sender, ticketAddress, bandAddress, amount, price, false);

        bytes memory data;
        // IDegenTickets(ticketAddress).setApprovalForAll(address(this), true);

        IDegenTickets(ticketAddress).safeTransferFrom(msg.sender, address(this), 1, amount, data);

        emit TicketListed(msg.sender, ticketAddress, price, amount);

    }

    function buyTickets(uint amount, address ticketAddress, address ticketOwner) public payable {
        TixForSale memory currentShow = ticketsByShow[ticketAddress][ticketOwner];
        uint salePrice = currentShow.price * amount;
        require(msg.value >= (salePrice), "Insufficient funds");

        uint bandFee = msg.value / bandPercent;

        payable(currentShow.bandAddress).transfer(bandFee);

        uint ownerAmount = msg.value - bandFee;
        payable(ticketOwner).transfer(ownerAmount);

        bytes memory data;

        IDegenTickets(ticketAddress).safeTransferFrom(address(this), msg.sender, 1, amount, data);

        currentShow.sold = true;
        currentShow.owner= msg.sender;

        emit TicketPurchased(msg.sender, ticketAddress, salePrice, amount);
    }

    function cancelListing(address ticketAddress, uint amount) public {
        TixForSale memory currentShow = ticketsByShow[ticketAddress][msg.sender];
        require(msg.sender == currentShow.owner, "not ticket owner");

        bytes memory data;

        IDegenTickets(ticketAddress).safeTransferFrom(address(this), msg.sender, 1, amount, data);

        emit ListingCancelled(ticketAddress, msg.sender, amount);
        
    }


    function updatePrice(address ticketAddress, uint newPrice) public{
        TixForSale storage currentShow = ticketsByShow[ticketAddress][msg.sender];
        require(msg.sender == currentShow.owner, "not ticket owner");

        currentShow.price = newPrice;
        
    }

    

    // helper and setter functions

    function setBandPercent(uint newPercent) public onlyAdmin{
        bandPercent = newPercent;
    }
}
