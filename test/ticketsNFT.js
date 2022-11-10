const { expect } = require("chai");
const {ethers} = require("hardhat")

describe("Tickets NFT Contract", () =>{
    let TicketsNFT, deployer, user1, user2, venueAddress, bandAddress

    beforeEach(async () =>{
        const accounts = await ethers.getSigners()
        deployer = accounts[0]
        user1 =accounts[1]
        user2 = accounts[2]
        venueAddress = accounts[10]
        bandAddress = accounts[9]

        const nftContractFactory = await ethers.getContractFactory("TicketsNFT")
        TicketsNFT = await nftContractFactory.deploy("ACDC", "BIB", 25000, venueAddress.address, bandAddress.address, 10 )
        await TicketsNFT.deployed()



    })
    it("checks the admin / band name / initials", async () =>{
        expect(await TicketsNFT.admin()).to.equal(deployer.address)
        expect(await TicketsNFT.bandName()).to.equal("ACDC")
        expect(await TicketsNFT.TourNameInitials()).to.equal("BIB")

    })
    it("checks the band and venue address", async () =>{
        expect(await TicketsNFT.venue()).to.equal(venueAddress.address)
        expect(await TicketsNFT.Band()).to.equal(bandAddress.address)
    })
})