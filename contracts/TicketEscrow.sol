// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract TicketEscrow{
    address public admin;
    address public ticketContract;
    address public createShowContract;

    modifier onlyAdmin {
        require(msg.sender == admin, "only admin can call function");
        _;
    }

    modifier onlyShowContract {
        require(msg.sender == createShowContract, "only callable by show contract");
        _;
    }

    constructor(){
        admin = msg.sender;
        createShowContract = msg.sender;
    }

    receive() external payable{}

    function viewBalance() external view returns(uint){
        return address(this).balance;

    }
    
    function setTicketContract(address _tixContract) external onlyAdmin{
        ticketContract = _tixContract;
    }
    function setShowContract(address _showContract) external onlyAdmin{
        createShowContract = _showContract;
    }

    // function returnFunds() external payable onlyAdmin{
    //     payable(admin).transfer(address(this).balance);
    // }

    function releaseFunds() external payable onlyShowContract{
        payable(ticketContract).transfer(address(this).balance);
    }

    

}