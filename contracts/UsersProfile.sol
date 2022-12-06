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
    mapping(address=>string[]) public userComments;

    // ratings mappings for users has rated bool
    // total num of ppl who rated
    // total amount of ratings added up
    mapping(address=>mapping(address=>bool)) public hasRated;
    mapping(address=>uint) private totalNumOfRates;
    mapping(address=> uint) private ratingsAddedUp;

    // mapping of address to address array of 'liked' artist
    mapping(address=>address[]) public followList;

    mapping(address=>address[]) public showsAttended;

    address[] public allUser;

    struct UserProfile{
        address user;
        string username;
        string status;
        uint profileNFT;
        bool verifiedReseller;
        uint totalRates;
        uint likes;
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
                newTokenId,
                false,
                0,
                0
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


    function rateUser(address userToRate, uint rating) public {
        require(rating <= 5, "cannot rate over 5");
        require(hasRated[userToRate][msg.sender] == false, "already rated");
        hasRated[userToRate][msg.sender] = true;

        totalNumOfRates[userToRate]++;
        ratingsAddedUp[userToRate] += rating;


    }



    function calculateUsersRating(address userToRate) public returns(uint) {
        uint pplRated = totalNumOfRates[userToRate];
        uint totalRates = ratingsAddedUp[userToRate];

        uint rating = (totalRates / pplRated);
        
        return profileByAddress[userToRate].totalRates = rating;

    }


    function followUser(address addyToFollow) public {
        require(profileByAddress[msg.sender].user != address(0), "must create profile");
        followList[msg.sender].push(addyToFollow);

    }




    function sendComment(address userToComment, string memory comment) public {
        require(profileByAddress[msg.sender].user != address(0), "must create profile");
        userComments[userToComment].push(comment);
    }

    function likeUser(address userToLike) public returns(uint) {
        require(profileByAddress[msg.sender].user != address(0), "must create profile");

        return profileByAddress[userToLike].likes++;

    }

    function unlikeUser(address userToUnlike) public returns(uint){
        require(profileByAddress[msg.sender].user != address(0), "must create profile");

        return profileByAddress[userToUnlike].likes--;
    }

    


    // social function

    function addToShowsAttended(address showTixAddy) public {
        require(profileByAddress[msg.sender].user != address(0), "must create profile");

        showsAttended[msg.sender].push(showTixAddy);
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