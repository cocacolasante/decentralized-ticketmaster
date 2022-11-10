const { expect } = require("chai");
const {ethers} = require("hardhat")

describe("Tickets NFT Contract", () =>{
    let TicketsNFT, deployer, user1, user2, venueAddress, bandAddress

    beforeEach(async () =>{
        const accounts = await ethers.getSigners()
        deployer = accounts[0]
        user1 =accounts[1]
        user2 = accounts[2]
        venueAddress = accounts[20]
        bandAddress = accounts[19]

        const nftContractFactory = await ethers.getContractFactory("TicketsNFT")
        TicketsNFT = await nftContractFactory.deploy("ACDC", "BIB", 25000, venueAddress.address, bandAddress.address, 10 )
        await TicketsNFT.deployed()

        console.log(`contract deployed to ${TicketsNFT.address}`)


    })
    it("checks the band and tour name", async () =>{
        expect(await TicketsNFT.admin()).to.equal(deployer.address)

    })
})