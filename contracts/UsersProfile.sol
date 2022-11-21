// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract UsersProfile is ERC721URIStorage{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    
    address public admin;

    mapping(uint=>UserProfile) public usersProfileList;
    mapping(address=>UserProfile) public profileByAddress;


    struct UserProfile{
        string username;
        string status;
        address[] showsAttended;
        int userRating;
        string[] usersComments;
        uint profileNFT;
        bool verifiedReseller;
    }

    constructor()ERC721("Cryptix Profiles", "CPF"){
        admin = msg.sender;
    }



}