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


    // mapping of profile users to comment sender to comment
    // first address should be of the user who someone is writing a comment to their wall on
    mapping(address=>mapping(address=>string)) public userComments;

    mapping(address=>address[]) public showsAttended;

    address[] public allUser;

    struct UserProfile{
        address user;
        string username;
        string status;
        int userRating;
        uint profileNFT;
        bool verifiedReseller;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "only Admin can call function");
        _;
    }

    constructor()ERC721("Cryptix Profiles", "CPF"){
        admin = msg.sender;
    }

    function mint(string memory tokenURI) external returns(uint){
        _tokenIds.increment();

        uint newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        if(profileByAddress[msg.sender].user == address(0)){

            profileByAddress[msg.sender] = UserProfile(
                msg.sender,
                "username",
                "status",
                0,
                newTokenId,
                false
            );

            allUser.push(msg.sender);
        }

        _setTokenURI(newTokenId, tokenURI);

        setProfileNFT(newTokenId);

        return newTokenId;

    }

    // profile setter function

    function setProfileNFT(uint newTokenID) public {
        UserProfile storage currentUser = profileByAddress[msg.sender];
        require(msg.sender == ownerOf(newTokenID));
        require(msg.sender == currentUser.user, "not authorized user");

        
        currentUser.profileNFT = newTokenID;
    }

    function setUsername(string memory newUsername) public {
        UserProfile storage currentUser = profileByAddress[msg.sender];
        require(msg.sender == currentUser.user, "not authorized user");

        
        currentUser.username = newUsername;
    }

    function setUserStatus(string memory newStatus) public {
        UserProfile storage currentUser = profileByAddress[msg.sender];
        require(msg.sender == currentUser.user, "not authorized user");

        currentUser.status = newStatus;

    }

    function rateUser(uint rating) public {
        
    }



    // admin function

    function VerifyUser(address userToVerify) public onlyAdmin{
        UserProfile storage currentUser = profileByAddress[userToVerify];

        currentUser.verifiedReseller = true;
    }

    // getter functions

    function returnTokenCount() public view returns(uint){
        return _tokenIds.current();
    }

}