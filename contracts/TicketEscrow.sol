// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract TicketEscrow{
    address public admin;
    address public ticketContract;

    modifier onlyAdmin {
        require(msg.sender == admin, "only admin can call function");
        _;
    }

    modifier onlyTicketContract {
        require(msg.sender == ticketContract, "only callable by ticket contract");
        _;
    }

    constructor(){
        admin = msg.sender;
    }

    receive() external payable{}

    function viewBalance() external view returns(uint){
        return address(this).balance;

    }
    
    function setTicketContract(address _tixContract) external onlyAdmin{
        ticketContract = _tixContract;
    }

    // function returnFunds() external payable onlyAdmin{
    //     payable(admin).transfer(address(this).balance);
    // }

    function releaseFunds() external payable onlyTicketContract{
        payable(ticketContract).transfer(address(this).balance);
    }

    

}