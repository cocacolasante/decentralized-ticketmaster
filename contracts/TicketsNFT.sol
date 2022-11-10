// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract TicketsNFT is ERC721URIStorage{
    string public bandName;
    string public TourNameInitials;

    uint public maxTicketSupply;

    address payable public admin;
    address payable public Band;
    address payable public venue;


    uint public resaleFee;

    // only admin modifier

    modifier onlyAdmin{
        require(msg.sender == admin, "admin only function");
        _;
    }

    constructor(
        string memory _bandName, 
        string memory _tourNameInitials, 
        uint _maxSupply, 
        address _venueAddress, 
        address _bandAddress, 
        uint _resaleFee)
        ERC721(_bandName, _tourNameInitials){
            bandName = _bandName;
            TourNameInitials = _tourNameInitials;
            maxTicketSupply = _maxSupply;
            admin = payable(msg.sender);
            venue = payable(_venueAddress);
            venue = payable(_bandAddress);
            resaleFee = _resaleFee;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
       

        _transfer(from, to, tokenId);
    }

    

}
