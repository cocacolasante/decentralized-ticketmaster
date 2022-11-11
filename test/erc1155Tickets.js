const { expect } = require("chai");
const {ethers} = require("hardhat")
const degenTicketAbi = require("./contract-abis/degenTicketsabi.json")

describe("ERC1155 Ticket Contract", () =>{
    let TicketContract, deployer, user1, user2, user3, BandAddress, VenueAddress

    const SAMPLEURI = "SAMPLEURI"

    beforeEach(async () =>{
        const accounts = await ethers.getSigners();

        deployer = accounts[0]
        user1 = accounts[1]
        user2 = accounts[2]
        user3 = accounts[3]

        VenueAddress = accounts[10]
        BandAddress = accounts[9]

        const erc1155ContractFactory = await ethers.getContractFactory("DegenTickets")
        TicketContract = await erc1155ContractFactory.deploy(SAMPLEURI, 100, 10, BandAddress.address, VenueAddress.address, 500)
        await TicketContract.deployed()
        
        

    })
    describe("Deployment", () =>{

        it("checks the admin of the contract", async () =>{
            expect(await TicketContract.admin()).to.equal(deployer.address)
        })
        it("checks the band and venue address", async () =>{
            expect(await TicketContract.BandAddress()).to.equal(BandAddress.address)
            expect( await TicketContract.VenueAddress()).to.equal(VenueAddress.address)
    
        })
        it("checks the ticket price and band percentage and total tickets", async () =>{
            expect(await TicketContract.ticketPrice()).to.equal(100)
            expect(await TicketContract.bandTicketSalesPercent()).to.equal(10)
            expect(await TicketContract.maxSupply()).to.equal(500)
        })
        it("checks the current ticket count", async () =>{
            expect(await TicketContract.ticketCount()).to.equal(0)
        })
        

    })
    describe("Minting token Function", async () =>{
        let bandInitialBalance, venueInitialBalance
        beforeEach(async () =>{

            bandInitialBalance = await ethers.provider.getBalance(BandAddress.address)
            // eslint-disable-next-line no-undef
            bandInitialBalance = BigInt(bandInitialBalance)


            venueInitialBalance = await ethers.provider.getBalance(VenueAddress.address)
            // eslint-disable-next-line no-undef
            venueInitialBalance = BigInt(venueInitialBalance)


            await TicketContract.connect(user1).buyTickets(1, {value: 100})
        })
        it("checks the ticket count", async () =>{
            expect(await TicketContract.ticketCount()).to.equal(1)
        })
        it("checks the owners address tickets were minted", async () =>{
            expect(await TicketContract.balanceOf(user1.address, 1)).to.equal(1);
        })
        it("checks the funds were transfered to band", async () =>{
           
            let bandAferBalance = await ethers.provider.getBalance(BandAddress.address)
            // eslint-disable-next-line no-undef
            bandAferBalance = BigInt(bandAferBalance)
            // eslint-disable-next-line no-undef
            expect(bandAferBalance).to.equal(bandInitialBalance + BigInt(10))
        })
        it("checks the funds were sent to the venue", async () =>{
            let venueAfterBalance = await ethers.provider.getBalance(VenueAddress.address)
            // eslint-disable-next-line no-undef
            venueAfterBalance = BigInt(venueAfterBalance)
            // eslint-disable-next-line no-undef
            expect(venueAfterBalance).to.equal(venueInitialBalance + BigInt(90))
        })
    })
    describe("Create Show Contract", () =>{
        let CreateShowContract, newShowTickets, newShowTixContract
        beforeEach(async () =>{
            const showContractFactory = await ethers.getContractFactory("CreateShow")
            CreateShowContract = await showContractFactory.deploy()
            await CreateShowContract.deployed()

            await CreateShowContract.connect(user1).createNewShowTickets(SAMPLEURI, 100, 10, BandAddress.address, VenueAddress.address, 500)

            newShowTickets = await CreateShowContract.allContracts(1)

            // get the newly create contract

            newShowTixContract = new ethers.Contract(newShowTickets, degenTicketAbi.abi, ethers.provider)

            // console.log(await newShowTixContract.admin())
        })
        it("checks the new contracts address", async () =>{
            // test smart contract transfers admin from the smart contract to caller of the contract
            expect(await newShowTixContract.admin()).to.equal(user1.address)

        })
        it("checks the event was emitted", async () =>{
            expect(await CreateShowContract.connect(user2).createNewShowTickets(SAMPLEURI, 100, 10, BandAddress.address, VenueAddress.address, 500)).to.emit("DegenTickets", "ShowCreated")
        })
        
    })
})