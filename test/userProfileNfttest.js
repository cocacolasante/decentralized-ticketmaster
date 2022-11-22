const { expect } = require("chai");
const {ethers} = require("hardhat")
const hre = require("hardhat");

describe("Users Profile nft", () =>{
    let ProfileContract, deployer, user1, user2, user3

    const SAMPLEURI = "SAMPLE_URI"

    beforeEach(async () =>{
        const profileContractFactory = await ethers.getContractFactory("UsersProfile")
        ProfileContract = await profileContractFactory.deploy()
        await ProfileContract.deployed()

        // console.log(`Profile Contract Deployed to ${ProfileContract.address}`)
        
        const accounts = await ethers.getSigners()
        deployer = accounts[0]
        user1 = accounts[1]
        user2 = accounts[2]
        user3 = accounts[3]
    })
    it("Checks the admin of the profile contract", async () =>{
        expect(await ProfileContract.admin()).to.equal(deployer.address)

    })
    it("checks the name of the contract", async ()=>{
        expect(await ProfileContract.name()).to.equal("Cryptix Profiles")
    })
    describe("Mint function", async () =>{
        beforeEach(async () =>{
            await ProfileContract.connect(user1).mint(SAMPLEURI)
        })
        it("checks the token count", async () =>{
            expect(await ProfileContract.returnTokenCount()).to.equal(1)
        })
        it("checks the users balance", async () =>{
            expect(await ProfileContract.balanceOf(user1.address)).to.equal(1)
        })
        it("checks the token uri", async () =>{
            expect(await ProfileContract.tokenURI(1)).to.equal(SAMPLEURI)
        })
        describe("users Profile",  () =>{
            let profileStruct1, profileStruct2
            beforeEach(async () =>{
                profileStruct1 = await ProfileContract.profileByAddress(user1.address)

            })
            it("checks the token id is set", async () =>{
                expect(profileStruct1.profileNFT).to.equal(1)
            })
            it("checks set profile nft ", async () =>{
                await ProfileContract.connect(user1).mint("SAMPLEURI2")

                await ProfileContract.connect(user1).setProfileNFT(1)
                profileStruct1 = await ProfileContract.profileByAddress(user1.address)
                expect(profileStruct1.profileNFT).to.equal(1)

                await ProfileContract.connect(user1).setProfileNFT(2)
                profileStruct1 = await ProfileContract.profileByAddress(user1.address)
                expect(profileStruct1.profileNFT).to.equal(2)

            })
            it("checks the default values of the struct", async () =>{
                expect(profileStruct1.username).to.equal("username")
                expect(profileStruct1.status).to.equal("status")
                expect(profileStruct1.verifiedReseller).to.equal(false)
                expect(profileStruct1.userRating).to.equal(0)
            })
            it("checks the set username function", async () =>{
                await ProfileContract.connect(user1).setUsername("cocacola")
                profileStruct1 = await ProfileContract.profileByAddress(user1.address)
                expect(profileStruct1.username).to.equal("cocacola")
            })
            it("checks the set status function", async () =>{
                await ProfileContract.connect(user1).setUserStatus("Hello There")
                profileStruct1 = await ProfileContract.profileByAddress(user1.address)
                expect(profileStruct1.status).to.equal("Hello There")

            })
            it("checks the verify reseller function", async () =>{
                await ProfileContract.connect(deployer).VerifyUser(user1.address)
                profileStruct1 = await ProfileContract.profileByAddress(user1.address)
                expect(profileStruct1.verifiedReseller).to.equal(true)
            })
        })
    })
})