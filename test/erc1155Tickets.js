const { expect } = require("chai");
const {ethers} = require("hardhat")
const degenTicketAbi = require("./contract-abis/degenTicketsabi.json")
const escrowAbi = require("./contract-abis/escrowContract.json")
const {moveBlocks} = require("./testingutils/moveblock")
const {moveTime} = require("./testingutils/move-time")

describe("ERC1155 Ticket Contract", () =>{
    let TicketContract, deployer, user1, user2, user3, user4, BandAddress, VenueAddress, EscrowContract

    const SAMPLEURI = "SAMPLEURI"

    beforeEach(async () =>{
        const accounts = await ethers.getSigners();

        deployer = accounts[0]
        user1 = accounts[1]
        user2 = accounts[2]
        user3 = accounts[3]
        user4 = accounts[4]

        VenueAddress = accounts[10]
        BandAddress = accounts[9]

        const escrowContractFactory = await ethers.getContractFactory("TicketEscrow")
        EscrowContract = await escrowContractFactory.deploy()
        await EscrowContract.deployed()

        const erc1155ContractFactory = await ethers.getContractFactory("DegenTickets")
        TicketContract = await erc1155ContractFactory.deploy(SAMPLEURI, 100, 10, BandAddress.address, VenueAddress.address, 500, EscrowContract.address)
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


            // await TicketContract.connect(user1).buyTickets(1, {value: 100})
            await TicketContract.connect(user1).buyEscrowTickets(1, {value: 100})

        })
        it("checks the ticket count", async () =>{
            expect(await TicketContract.ticketCount()).to.equal(1)
        })
        it("checks the owners address tickets were minted", async () =>{
            expect(await TicketContract.balanceOf(user1.address, 1)).to.equal(1);
        })
        it("checks the balance of the escrow contract", async () =>{
            expect(await ethers.provider.getBalance(EscrowContract.address)).to.equal(100)
        })
        it("checks users can buy up to the max tickets per wallet", async () =>{
            await expect(TicketContract.connect(user3).buyEscrowTickets(9, {value: 400})).to.be.reverted

        })

    })
    describe("Create Show Contract", () =>{
        let CreateShowContract, newShowTickets, newShowTixContract
        beforeEach(async () =>{
            const showContractFactory = await ethers.getContractFactory("CreateShow")
            CreateShowContract = await showContractFactory.deploy()
            await CreateShowContract.deployed()

            await CreateShowContract.connect(user1).createNewShowTickets(SAMPLEURI, 100, 10, BandAddress.address, VenueAddress.address, 500, 1)

            newShowTickets = await CreateShowContract.allContracts(1)

            // get the newly create contract

            newShowTixContract = new ethers.Contract(newShowTickets, degenTicketAbi.abi, ethers.provider)


            // console.log(await newShowTixContract.admin())
        })
        it("checks the new contracts address", async () =>{
            // test smart contract transfers admin from the smart contract to caller of the contract
            // expect(await newShowTixContract.admin()).to.equal(user1.address)

        })
        it("checks the event was emitted", async () =>{
            expect( await CreateShowContract.connect(user2).createNewShowTickets(SAMPLEURI, 100, 10, BandAddress.address, VenueAddress.address, 500, 1)).to.emit("CreateShow", "ShowCreated")
        })

        
        
    })
    describe("Ticket Escrow contract deployment with create show contract", () =>{
        let CreateShowContract, newShowTickets, newShowTixContract, NewEscrowContract
        beforeEach(async () =>{
            const showContractFactory = await ethers.getContractFactory("CreateShow")
            CreateShowContract = await showContractFactory.deploy()
            await CreateShowContract.deployed()

            await CreateShowContract.connect(user1).createNewShowTickets(SAMPLEURI, 100, 10, BandAddress.address, VenueAddress.address, 500, 1)

            let newShowTix = await CreateShowContract.allShows(1)
            newShowTickets = newShowTix.ticketContract


            const newEscrowAddy = await CreateShowContract.allShows(1)
            const escrowAddy = newEscrowAddy.escrowContract 

            // get the newly create contracts

            newShowTixContract = new ethers.Contract(newShowTickets, degenTicketAbi.abi, ethers.provider)
            NewEscrowContract = new ethers.Contract(escrowAddy, escrowAbi.abi, ethers.provider)

            // console.log(await newShowTixContract.admin())
        })
        it("checks the admin", async () =>{
            expect(await NewEscrowContract.admin()).to.equal(CreateShowContract.address)
        })
        it("checks the balance and receive function", async () =>{
            expect(await NewEscrowContract.viewBalance()).to.equal(0)
            await user3.sendTransaction({
                to: NewEscrowContract.address,
                value: ethers.utils.parseEther("1.0"), // Sends exactly 1.0 ether
              });
              expect(await NewEscrowContract.viewBalance()).to.equal("1000000000000000000")
        })
        it("checks the contract address", async () =>{
            expect(await NewEscrowContract.admin()).to.equal(CreateShowContract.address)
            expect(await newShowTixContract.admin()).to.equal(CreateShowContract.address)
            expect(await NewEscrowContract.ticketContract()).to.equal(newShowTixContract.address)
            expect(await NewEscrowContract.createShowContract()).to.equal(CreateShowContract.address)

            expect(await newShowTixContract.BandAddress()).to.equal(BandAddress.address)



        })
        it("checks the release funds function", async () =>{

            await user3.sendTransaction({
                to: NewEscrowContract.address,
                value: ethers.utils.parseEther("1.0"), // Sends exactly 1.0 ether
                // value: "100", // Sends exactly 1.0 ether
              });
            
            console.log("Escrow Addy", await NewEscrowContract.admin())
            console.log("--------")
            console.log("Create show address", await CreateShowContract.address)
            console.log("--------")

            await moveBlocks(2)
            await moveTime(172800)

            await CreateShowContract.connect(deployer).payForShow(1)

            
            // expect(await ethers.provider.getBalance(BandAddress.address)).to.equal("100000000000000000")
            expect(await ethers.provider.getBalance(newShowTixContract.address)).to.equal(0)

            // console.log("Band balance", (await ethers.provider.getBalance(BandAddress.address)).toString())
            expect((await ethers.provider.getBalance(BandAddress.address)).toString()).to.equal("10000100000000000000000")


            // console.log("Venue Balance", (await ethers.provider.getBalance(VenueAddress.address)).toString())
            expect((await ethers.provider.getBalance(VenueAddress.address)).toString()).to.equal("10000900000000000000000")
            
            

        })
        it("checks the buy ticket function from new ticket contract", async () =>{
            await newShowTixContract.connect(user3).buyEscrowTickets(1, {value: 100})
            expect(await newShowTixContract.balanceOf(user3.address, 1)).to.equal(1)
            
        })
        it("checks the reschedule show function", async () =>{
            await CreateShowContract.connect(VenueAddress).rescheduleShow(1, 2)
            const currentShow = await CreateShowContract.allShows(1)
            expect(currentShow.date).to.equal(86400 + 86400 + 86400)
        })
        it("check the event was emitted")
        
        describe("refund functions and helpers", () =>{
            beforeEach(async () =>{
                await newShowTixContract.connect(user3).buyEscrowTickets(2, {value: 600})

                await newShowTixContract.connect(user2).buyEscrowTickets(2, {value: 200})
                await newShowTixContract.connect(BandAddress).buyEscrowTickets(2, {value: 200})
            })
            it("checks the current ticket holders function", async () =>{
                const ownerList = (await newShowTixContract._getAllOwner())
                expect(ownerList[0]).to.equal(user3.address)
                expect(ownerList[1]).to.equal(user2.address)
                expect(ownerList[2]).to.equal(BandAddress.address)

                

            })
            it("checks the send refund function", async () =>{
                let user2Balance = await ethers.provider.getBalance(user2.address)
                // eslint-disable-next-line no-undef
                user2Balance = BigInt(user2Balance)

                
                await CreateShowContract.connect(deployer).cancelShow(1)
                
                // eslint-disable-next-line no-undef
                expect(await ethers.provider.getBalance(user2.address)).to.equal(user2Balance + BigInt(200))
            })
            describe("Ticket Marketplace", async () =>{
                let MarketplaceContract
                beforeEach(async () =>{
                    const marketplaceFactory = await ethers.getContractFactory("TicketMarketplace")
                    MarketplaceContract = await marketplaceFactory.deploy()
                    await MarketplaceContract.deployed()

                    await MarketplaceContract.connect(deployer).setBandPercent(10);

                    // console.log(`Marketplace deployed to ${MarketplaceContract.address}`)
                })
                it("checks the admin of the marketplace", async () =>{
                    expect(await MarketplaceContract.admin()).to.equal(deployer.address)
                })
                it("checks the list ticket function", async () =>{
                    await newShowTixContract.connect(user3).setApprovalForAll(MarketplaceContract.address, true)
                    expect( await MarketplaceContract.connect(user3).listTickets(2, 100, newShowTixContract.address, BandAddress.address )).to.emit("TicketMarketplace", "TicketListed")
                    expect(await newShowTixContract.balanceOf(MarketplaceContract.address, 1)).to.equal(2)

                })
                it("checks the buy function", async () =>{
                    await newShowTixContract.connect(user3).setApprovalForAll(MarketplaceContract.address, true)
                    await MarketplaceContract.connect(user3).listTickets(2, 100, newShowTixContract.address, BandAddress.address )

                    await MarketplaceContract.connect(user4).buyTickets(2, newShowTixContract.address, user3.address, {value: 200});
                    expect(await newShowTixContract.balanceOf(user4.address, 1)).to.equal(2)
                })
                it("checks the cancel listing function", async () =>{
                    await newShowTixContract.connect(user3).setApprovalForAll(MarketplaceContract.address, true)
                    await MarketplaceContract.connect(user3).listTickets(2, 100, newShowTixContract.address, BandAddress.address )

                    expect(await MarketplaceContract.connect(user3).cancelListing(newShowTixContract.address, 2)).to.emit("DegenTickets", "ListingCancelled");
                    expect(await await newShowTixContract.balanceOf(MarketplaceContract.address, 1)).to.equal(0)
                })
                it("checks the resale funds were received by the band", async () =>{
                    let initialBalance = await ethers.provider.getBalance(BandAddress.address)
                    // eslint-disable-next-line no-undef
                    initialBalance = BigInt(initialBalance)

                    await newShowTixContract.connect(user3).setApprovalForAll(MarketplaceContract.address, true)
                    await MarketplaceContract.connect(user3).listTickets(2, 100, newShowTixContract.address, BandAddress.address )
                    await MarketplaceContract.connect(user4).buyTickets(2, newShowTixContract.address, user3.address, {value: 200});


                    // eslint-disable-next-line no-undef
                    expect(await ethers.provider.getBalance(BandAddress.address)).to.equal(initialBalance + BigInt(20))
                })
                it("checks the owner received their funds", async () =>{
                    
                    await newShowTixContract.connect(user3).setApprovalForAll(MarketplaceContract.address, true)
                    await MarketplaceContract.connect(user3).listTickets(2, 100, newShowTixContract.address, BandAddress.address )
                    let initialBalance = await ethers.provider.getBalance(user3.address)
                    // eslint-disable-next-line no-undef
                    initialBalance = BigInt(initialBalance)
                    await MarketplaceContract.connect(user4).buyTickets(2, newShowTixContract.address, user3.address, {value: 200});


                    // eslint-disable-next-line no-undef
                    expect(await ethers.provider.getBalance(user3.address)).to.equal(initialBalance + BigInt(180))
                })
            })
        })

        
    })
})