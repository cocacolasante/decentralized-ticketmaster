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
        describe("Rating and Comments", () =>{
            beforeEach(async () =>{
                await ProfileContract.connect(user2).mint(SAMPLEURI)
                await ProfileContract.connect(user2).rateUser(user1.address, 4)
            })
            it("checks the users rating", async () =>{
                await ProfileContract.calculateUsersRating(user1.address)
                const profileStruct = await ProfileContract.profileByAddress(user1.address)
                expect(profileStruct.totalRates).to.equal(4)
            })
            it("checks the rating average works", async () =>{
                await ProfileContract.connect(user3).mint(SAMPLEURI)
                await ProfileContract.connect(user3).rateUser(user1.address, 2)
                await ProfileContract.calculateUsersRating(user1.address)
                const profileStruct = await ProfileContract.profileByAddress(user1.address)
                expect(profileStruct.totalRates).to.equal(3)
            })
            it("checks the follow user function", async () =>{
                await ProfileContract.connect(user2).followUser(user1.address)
                expect(await ProfileContract.followList(user2.address, 0)).to.equal(user1.address)
            })
            it("checks the send comment function", async () =>{
                await ProfileContract.connect(user2).sendComment(user1.address, "Hello there")
                expect(await ProfileContract.userComments(user1.address, 0)).to.equal("Hello there")
                await ProfileContract.connect(user2).sendComment(user1.address, "General Kenobi")
                expect(await ProfileContract.userComments(user1.address, 1)).to.equal("General Kenobi")
            })
            it("checks the failcase 'needs a profile'", async () =>{
                await expect(ProfileContract.connect(user3).sendComment(user1.address, "Youre a bold")).to.be.revertedWith("must create profile")

            })
            it("checks the like function", async () =>{
                await ProfileContract.connect(user2).likeUser(user1.address)
                let profileStruct = await ProfileContract.profileByAddress(user1.address)
                expect(profileStruct.likes).to.equal(1)
            })
            it("checks the unlike function", async () =>{
                await ProfileContract.connect(user2).likeUser(user1.address)
                let profileStruct = await ProfileContract.profileByAddress(user1.address)
                expect(profileStruct.likes).to.equal(1)
                await ProfileContract.connect(user2).unlikeUser(user1.address)
                profileStruct = await ProfileContract.profileByAddress(user1.address)
                expect(profileStruct.likes).to.equal(0)
            })


        })
    })
})