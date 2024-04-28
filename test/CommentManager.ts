import {
    loadFixture, time,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Comment Manager", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deploySocialMediaPlatform() {

        // Contracts are deployed using the first signer/account by default
        const [user] = await ethers.getSigners();

        const CommentManager = await ethers.getContractFactory("CommentManager");
        const commentManagerContract = await CommentManager.deploy();

        return { user, commentManagerContract };
    }

    const EXAMPLE_COMMENT = "This is a comment";
    const BAD_EXAMPLE_COMMENT = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies";

    let commentManagerContract: any;
    let user: any;

    beforeEach(async function () {
        const { commentManagerContract: commentManager, user: u1 } = await loadFixture(deploySocialMediaPlatform);

        commentManagerContract = commentManager;
        user = u1;
    });

    describe("Adding comment", function () {
        it("Should add a comment", async function () {
            await expect(commentManagerContract.connect(user)._addComment(1, EXAMPLE_COMMENT, user.address)).not.to.be.reverted;
        });

        it("Should not add a comment due to comment lenght zero", async function () {
            await expect(commentManagerContract.connect(user)._addComment(2, "", user.address)).to.be.revertedWith("Comment cannot be empty");
        });

        it("Should not add a comment due to invalid comment lenght", async function () {
            await expect(commentManagerContract.connect(user)._addComment(1, BAD_EXAMPLE_COMMENT, user.address)).to.be.revertedWith("Comment exceeds maximum length");
        });
    });

    describe("Removing comment", function () {
        beforeEach(async function () {
            await commentManagerContract.connect(user)._addComment(1, EXAMPLE_COMMENT, user.address);
        });

        const FAKE_USER_ADDRESS = "0x742d35Cc6634C0532925a3b844Bc454e4438f44e";

        it("Should remove a comment", async function () {
            await expect(commentManagerContract.connect(user)._removeComment(1, 0, user.address)).not.to.be.reverted;
        });

        it("Should not rmeove a comment due to invalid comment id", async function () {
            await expect(commentManagerContract.connect(user)._removeComment(1, 2, user.address)).to.be.revertedWith("Invalid comment Id");
        });

        it("Should not remove a comment due to invalid sender address", async function () {
            await expect(commentManagerContract.connect(user)._removeComment(1, 0, FAKE_USER_ADDRESS)).to.be.revertedWith("You can only remove your own comments");
        });
    });

    describe("Retrieving a comment", function () {
        beforeEach(async function () {
            await commentManagerContract._addComment(1, EXAMPLE_COMMENT, user.address);
        });

        it("Should retrieve comment author", async function () {
            const comment = await commentManagerContract._getComment(1, 0);
            expect(comment.author).to.eq(user.address);
        });

        it("Should retrieve comment content", async function () {
            const comment = await commentManagerContract._getComment(1, 0);
            expect(comment.content).to.eq(EXAMPLE_COMMENT);
        });

        it("Should retrieve correct comment timestamp", async function () {
            const comment = await commentManagerContract._getComment(1, 0);
            expect(comment.timestamp).to.have.lengthOf.above(0);
        });
    });
});