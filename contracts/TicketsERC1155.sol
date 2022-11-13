// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

import "hardhat/console.sol";

// this contract only supports one type of ticket: General Admission

contract DegenTickets is ERC1155 {
    address public admin;
    address public escrowContract;

    uint public maxSupply;
    uint public ticketCount;

    address public BandAddress;
    address public VenueAddress;

    uint public bandTicketSalesPercent;

    string public date;

    uint public ticketPrice;

    bool public showCanceled;

    modifier onlyAdmin {
        require(msg.sender == admin, "only admin");
        _;
    }

    modifier notCancelled {
        require(showCanceled == false, "show was cancelled");
        _;
    }

    // declaring amounts in constructor for price, percentage to band, band address, venue address, max supply
    constructor(
            string memory tokenUri, 
            uint _ticketPrice, 
            uint _bandTicketSalesPercent, 
            address _bandAddress, 
            address _venueAddress,
            uint _maxSupply,
            address _escrowContract
        ) ERC1155(tokenUri) {
        admin = payable(msg.sender);
        ticketPrice = _ticketPrice;
        bandTicketSalesPercent = _bandTicketSalesPercent;
        BandAddress = _bandAddress;
        VenueAddress = _venueAddress;
        maxSupply = _maxSupply;
        escrowContract = _escrowContract;

    }

    function setURI(string memory newuri) public onlyAdmin notCancelled {
        _setURI(newuri);
    }

    // amount used to for amount of tickets purchased
    // id will always be 1 for this contract as this one supports one ticket type
    function buyTickets(uint256 amount)
        public
        payable
        notCancelled
    {
        require(msg.value >= ticketPrice, "Pay required minimum");
        require(maxSupply >  ticketCount + amount, "Not enouugh tickets left or sold out");

        // declaring id as 1 for metadata uri purposes 
        uint256 id = 1;
        // declaring data to minimize inputs
        bytes memory data;

        uint sendToBand = (msg.value * bandTicketSalesPercent) / 100;

        payable(BandAddress).transfer(sendToBand);
        payable(VenueAddress).transfer(msg.value - sendToBand);

        _mint(msg.sender, id, amount, data);

        // adding new ticket purchases to total ticket count
        ticketCount += amount;

    }

    // buy tickets function to send funds to escrow contract

    function buyEscrowTickets(uint amount)public payable notCancelled{
        require(msg.value >= ticketPrice, "Pay required minimum");
        require(maxSupply >  ticketCount + amount, "Not enouugh tickets left or sold out");

        // declaring id as 1 for metadata uri purposes 
        uint256 id = 1;
        // declaring data to minimize inputs
        bytes memory data;

        payable(address(escrowContract)).transfer(msg.value);


        _mint(msg.sender, id, amount, data);

        // adding new ticket purchases to total ticket count
        ticketCount += amount;

    }

    function payBandAndVenue() external payable onlyAdmin{
        uint bandAmount = (address(escrowContract).balance / bandTicketSalesPercent) * 100;
        

        payable(BandAddress).transfer(bandAmount);
        payable(VenueAddress).transfer(msg.value - bandAmount);

    }


    function changeAdmin(address newAdmin) public onlyAdmin notCancelled{
        admin = newAdmin;
    }



    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override
        
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function setDate(string memory newDate) external onlyAdmin notCancelled {
        date = newDate;
    }

    function cancelShow() external onlyAdmin{
        showCanceled = true;
    }
}