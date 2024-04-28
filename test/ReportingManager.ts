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

    beforeEach(async function () {
        const { reportingManagerContract: reportingManager, user: u1 } = await loadFixture(deploySocialMediaPlatform);

        reportingManagerContract = reportingManager;
        user = u1;
    });

    describe("Adding moderator", function () {
        it("Should add a moderator", async function () {
            expect(await reportingManagerContract._addModerator)
        });
    });
});