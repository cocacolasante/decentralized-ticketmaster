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

    uint public maxTixPerWallet = 8;

    address[] public ticketOwners;




    modifier onlyAdmin {
        require(msg.sender == admin, "only admin");
        _;
    }

    modifier notCancelled {
        require(showCanceled == false, "show was cancelled");
        _;
    }
    modifier underMaxTix(uint amount) {
        require(balanceOf(msg.sender, 1) + amount <= maxTixPerWallet, "max tickets purchased");
        _;
    }

    receive() external payable{}


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
    // buy tickets function to send funds to escrow contract

    // id will always be 1 for this contract as this one supports one ticket type
    function buyEscrowTickets(uint amount) public payable notCancelled underMaxTix(amount){
        require(msg.value >= ticketPrice, "Pay for tix");
        require(maxSupply >  ticketCount + amount, "No tickets left");

        // declaring id as 1 for metadata uri purposes 
        uint256 id = 1;
        // declaring data to minimize inputs
        bytes memory data;

        payable(address(escrowContract)).transfer(msg.value);


        _mint(msg.sender, id, amount, data);
        
        ticketOwners.push(msg.sender);
 

        // adding new ticket purchases to total ticket count
        ticketCount += amount;

    }

    // add back     amount = (amount - ((amount * fee) / 1000000));


    function payBandAndVenue() external payable onlyAdmin{
        uint bandAmount = (address(this).balance / bandTicketSalesPercent );


        
        // uint venueAmount = (address(this).balance - bandAmount);
        payable(BandAddress).transfer(bandAmount);
        payable(VenueAddress).transfer((address(this).balance));

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


    function setMaxTicketPerWallet(uint newLimit) public onlyAdmin {
        maxTixPerWallet = newLimit;
    }

    function _getAllOwner() public view returns(address[] memory){
        address[] memory currentOwners = new address[](ticketOwners.length);
        uint counterIndex;
        for(uint i = 0; i < ticketOwners.length;){
            if(balanceOf(ticketOwners[i], 1) > 0){
                currentOwners[counterIndex] = ticketOwners[i];
                counterIndex++;
            }
         i++;
        }
        return currentOwners;
    }






    // function getRefund() public {
    //     for(uint i = 0; i < ticketCount;){
    //         if(balanceOf(ticketOwners[i], 1) > 0){
    //             payable(ticketOwners[i]).transfer(ticketPrice);
    //         }
    //     }
    // }
}
