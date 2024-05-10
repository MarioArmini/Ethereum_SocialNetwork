import {
    loadFixture, time,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Reporting Manager", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deploySocialMediaPlatform() {

        // Contracts are deployed using the first signer/account by default
        const [user] = await ethers.getSigners();

        const ReportingManager = await ethers.getContractFactory("ReportingManager");
        const reportingManagerContract = await ReportingManager.deploy();

        return { user, reportingManagerContract };
    }

    let reportingManagerContract: any;
    let user: any;
    const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
    const FAKE_ADDRESS = "0x71C7656EC7ab88b098defB751B7401B5f6d8976F";

    beforeEach(async function () {
        const { reportingManagerContract: reportingManager, user: u1 } = await loadFixture(deploySocialMediaPlatform);

        reportingManagerContract = reportingManager;
        user = u1;
    });

    describe("Adding moderator", function () {
        it("Should add a moderator", async function () {
            await expect(reportingManagerContract._addModerator(user.address)).not.to.be.reverted;
        });

        it("Should not add zero address as moderator", async function () {
            await expect(reportingManagerContract._addModerator(ZERO_ADDRESS)).to.be.revertedWith("Cannot add zero address");
        });
    });

    describe("Checking moderator", function () {
        it("Should check a moderator", async function () {
            await reportingManagerContract._addModerator(user.address);
            expect(await reportingManagerContract._isModerator(user.address)).to.be.true;
        });
    });

    describe("Removing moderator", function () {
        it("Should remove a moderator", async function () {
            await reportingManagerContract._addModerator(user.address);
            await reportingManagerContract._removeModerator(user.address);
            expect(await reportingManagerContract._isModerator(user.address)).to.be.false;
        });

        it("Should not remove a moderator due to invalid address", async function () {
            await expect(reportingManagerContract._removeModerator(FAKE_ADDRESS)).to.be.revertedWith("Address is not a moderator");
        });
    });
});