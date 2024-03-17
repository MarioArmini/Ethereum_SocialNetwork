import {
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Social Media Platform", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploySocialMediaPlatform() {

    // Contracts are deployed using the first signer/account by default
    const [owner, moderator1, moderator2, user1, user2] = await ethers.getSigners();

    const SocialMediaPlatform = await ethers.getContractFactory("SocialMediaPlatform");
    const socialMediaPlatform = await SocialMediaPlatform.deploy(owner.address);

    return { socialMediaPlatform, owner, moderator1, moderator2, user1, user2 };
  }

  const EXAMPLE_IMG_HASH = "0x7B502C3A1F48C8609AE212CDFB639DEE39673F5E";
  const EXAMPLE_CAPTION = "This is a caption example";
  const BAD_EXAMPLE_CAPTION = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies";
  const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
  const EXAMPLE_CAPTION_UPDATE = "This is a caption updated";
  const EXAMPLE_IMG_HASH_UPDATED = "0x6T922C3A1F48C6609AE212CDFB639DXC39673F5E";

  const customTimestamp = Math.floor(Date.now() / 1000) + 60; // 60 seconds into the future =)

  describe("Post management", function () {
    describe("Post creation", function () {
      it("Should create post", async function () {
        const { socialMediaPlatform, user1 } = await loadFixture(deploySocialMediaPlatform);

        await ethers.provider.send("evm_setNextBlockTimestamp", [customTimestamp]);

        await expect(socialMediaPlatform.connect(user1).createPost(EXAMPLE_CAPTION, EXAMPLE_IMG_HASH)).not.to.be.reverted;
      });

      it("Should not create post due to invalid caption lenght", async function () {
        const { socialMediaPlatform, user1 } = await loadFixture(deploySocialMediaPlatform);

        await expect(socialMediaPlatform.connect(user1).createPost(BAD_EXAMPLE_CAPTION, EXAMPLE_IMG_HASH)).to.be.revertedWith("Caption exceeds maximum length");
      });

      it("Events", async function () {
        const { socialMediaPlatform, user1 } = await loadFixture(deploySocialMediaPlatform);

        await ethers.provider.send("evm_setNextBlockTimestamp", [customTimestamp]);

        await expect(socialMediaPlatform.connect(user1).createPost(EXAMPLE_CAPTION, EXAMPLE_IMG_HASH)).to.emit(socialMediaPlatform, "PostCreated");
      });
    });

    describe("Get post", function () {
      it("Should get post", async function () {
        const { socialMediaPlatform, user1 } = await loadFixture(deploySocialMediaPlatform);

        await ethers.provider.send("evm_setNextBlockTimestamp", [customTimestamp]);

        await socialMediaPlatform.connect(user1).createPost(EXAMPLE_CAPTION, EXAMPLE_IMG_HASH);

        await expect(socialMediaPlatform.getPost(1)).not.to.be.reverted;
      });

      it("Should retrieve post informations", async function () {
        const { socialMediaPlatform, user1 } = await loadFixture(deploySocialMediaPlatform);

        await ethers.provider.send("evm_setNextBlockTimestamp", [customTimestamp]);

        await socialMediaPlatform.connect(user1).createPost(EXAMPLE_CAPTION, EXAMPLE_IMG_HASH);

        const [
          author,
          caption,
          imageUrlIPFSHash,
          likes,
          supporters,
          commentsCount,
          flagged,
          reporters,
          isVisible,
          moderatorAgent,
          timeStamp,
          latestChangesTimeStamp
        ] = await socialMediaPlatform.connect(user1).getPost(1);

        expect(author).to.equal(user1.address);
        expect(caption).to.equal(EXAMPLE_CAPTION);
        expect(likes).to.equal(0);
        expect(supporters).to.be.an('array').that.is.empty;
        expect(commentsCount).to.equal(0);
        expect(flagged).to.be.false;
        expect(reporters).to.be.an('array').that.is.empty;
        expect(isVisible).to.be.true;
        expect(moderatorAgent).to.be.equal(ZERO_ADDRESS);
        expect(timeStamp).to.equal(customTimestamp);
        expect(latestChangesTimeStamp).to.equal(customTimestamp);
        expect(imageUrlIPFSHash).to.equal(EXAMPLE_IMG_HASH);
      });

      it("Should not get post due to invalid post id", async function () {
        const { socialMediaPlatform, user1 } = await loadFixture(deploySocialMediaPlatform);

        await ethers.provider.send("evm_setNextBlockTimestamp", [customTimestamp]);

        await socialMediaPlatform.connect(user1).createPost(EXAMPLE_CAPTION, EXAMPLE_IMG_HASH);

        await expect(socialMediaPlatform.getPost(2)).to.be.revertedWith("Invalid post ID");
      });
    });

    describe("Post edit", function () {

      let socialMediaPlatform: any;
      let user1: any;
      let user2: any;

      beforeEach(async function () {
        const { socialMediaPlatform: platform, user1: u1, user2: u2 } = await loadFixture(deploySocialMediaPlatform);

        socialMediaPlatform = platform;
        user1 = u1;
        user2 = u2;

        await ethers.provider.send("evm_setNextBlockTimestamp", [customTimestamp]);

        await socialMediaPlatform.connect(user1).createPost(EXAMPLE_CAPTION, EXAMPLE_IMG_HASH);
      });

      it("Should edit post", async function () {
        await expect(socialMediaPlatform.connect(user1).editPost(EXAMPLE_CAPTION_UPDATE, EXAMPLE_IMG_HASH_UPDATED, 1)).not.to.be.reverted;
      });

      it("Should values be updated", async function () {
        await socialMediaPlatform.connect(user1).editPost(EXAMPLE_CAPTION_UPDATE, EXAMPLE_IMG_HASH_UPDATED, 1);

        const [author, caption, imageUrlIPFSHash, latestChangesTimeStamp] = await socialMediaPlatform.connect(user1).getPost(1);

        expect(caption).to.equal(EXAMPLE_CAPTION_UPDATE);
        expect(imageUrlIPFSHash).to.equal(EXAMPLE_IMG_HASH_UPDATED);
        expect(latestChangesTimeStamp).to.equal(0);
      });

      it("Should not edit post due to invalid caption lenght", async function () {
        await expect(socialMediaPlatform.connect(user1).editPost(BAD_EXAMPLE_CAPTION, EXAMPLE_IMG_HASH_UPDATED, 1)).to.be.revertedWith("Caption exceeds maximum length");
      });

      it("Should not edit post due to invalid post id", async function () {
        await expect(socialMediaPlatform.connect(user1).editPost(EXAMPLE_CAPTION_UPDATE, EXAMPLE_IMG_HASH_UPDATED, 2)).to.be.revertedWith("Invalid post ID");
      });

      it("Should not edit post due to invalid sender address", async function () {
        await expect(socialMediaPlatform.connect(user2).editPost(EXAMPLE_CAPTION_UPDATE, EXAMPLE_IMG_HASH_UPDATED, 1)).to.be.revertedWith("Sender must be the Author");
      });

      it("Events", async function () {
        await expect(socialMediaPlatform.connect(user1).editPost(EXAMPLE_CAPTION_UPDATE, EXAMPLE_IMG_HASH_UPDATED, 1)).to.emit(socialMediaPlatform, "PostModified");
      });
    });

    describe("Post delete", function () {

      let socialMediaPlatform: any;
      let user1: any;
      let user2: any;

      beforeEach(async function () {
        const { socialMediaPlatform: platform, user1: u1, user2: u2 } = await loadFixture(deploySocialMediaPlatform);

        socialMediaPlatform = platform;
        user1 = u1;
        user2 = u2;

        await ethers.provider.send("evm_setNextBlockTimestamp", [customTimestamp]);

        await socialMediaPlatform.connect(user1).createPost(EXAMPLE_CAPTION, EXAMPLE_IMG_HASH);
      });

      it("Should delete post", async function () {
        await expect(socialMediaPlatform.connect(user1).deletePost(1)).not.to.be.reverted;
      });

      it("Post should be invisible", async function () {
        await socialMediaPlatform.connect(user1).deletePost(1);

        await expect(socialMediaPlatform.getPost(1)).to.be.revertedWith("Post is not visible");
      });

      it("Should not delete post due to invalid post id", async function () {
        await expect(socialMediaPlatform.connect(user1).deletePost(2)).to.be.revertedWith("Invalid post ID");
      });

      it("Should not delete post due to invalid sender address", async function () {
        await expect(socialMediaPlatform.connect(user2).deletePost(1)).to.be.revertedWith("Sender must be the Author");
      });

      it("Events", async function () {
        await expect(socialMediaPlatform.connect(user1).deletePost(1)).to.emit(socialMediaPlatform, "PostDeleted");
      });
    });
  });

  describe("Likes", function () {
    let socialMediaPlatform: any;
    let user1: any;
    let user2: any;

    beforeEach(async function () {
      const { socialMediaPlatform: platform, user1: u1, user2: u2 } = await loadFixture(deploySocialMediaPlatform);

      socialMediaPlatform = platform;
      user1 = u1;
      user2 = u2;

      await ethers.provider.send("evm_setNextBlockTimestamp", [customTimestamp]);

      await socialMediaPlatform.connect(user1).createPost(EXAMPLE_CAPTION, EXAMPLE_IMG_HASH);
    });

    describe("Adding likes", function () {
      it("Should add a like", async function () {
        await expect(socialMediaPlatform.connect(user2).likePost(1)).not.to.be.reverted;
      });

      it("Should update likes count", async function () {
        await socialMediaPlatform.connect(user2).likePost(1);

        const [author, caption, imageUrlIPFSHash, likes] = await socialMediaPlatform.getPost(1);

        expect(likes).to.equal(1);
      });

      it("Should update supporters", async function () {
        await socialMediaPlatform.connect(user2).likePost(1);

        const [author, caption, imageUrlIPFSHash, likes, supporters] = await socialMediaPlatform.getPost(1);

        expect(supporters).to.include(user2.address);
      });

      it("Should not add a like due to invalid post id", async function () {
        await expect(socialMediaPlatform.connect(user2).likePost(2)).to.be.revertedWith("Invalid post ID");
      });
    });

    describe("Removing likes", function () {

      beforeEach(async function () {
        await socialMediaPlatform.connect(user2).likePost(1);
      });

      it("Should remove a like", async function () {
        await expect(socialMediaPlatform.connect(user2).removeLike(1)).not.to.be.reverted;
      });

      it("Should update likes count", async function () {
        await socialMediaPlatform.connect(user2).removeLike(1);

        const [author, caption, imageUrlIPFSHash, likes] = await socialMediaPlatform.getPost(1);

        expect(likes).to.equal(0);
      });

      it("Should update supporters", async function () {
        await socialMediaPlatform.connect(user2).removeLike(1);

        const [author, caption, imageUrlIPFSHash, likes, supporters] = await socialMediaPlatform.getPost(1);

        expect(supporters).not.to.include(user2.address);
      });

      it("Should not add a like due to invalid post id", async function () {
        await expect(socialMediaPlatform.connect(user2).removeLike(2)).to.be.revertedWith("Invalid post ID");
      });
    });
  });

  describe("Comments", function () {

    const EXAMPLE_COMMENT = "This is a comment";

    let socialMediaPlatform: any;
    let user1: any;
    let user2: any;

    beforeEach(async function () {
      const { socialMediaPlatform: platform, user1: u1, user2: u2 } = await loadFixture(deploySocialMediaPlatform);

      socialMediaPlatform = platform;
      user1 = u1;
      user2 = u2;

      await ethers.provider.send("evm_setNextBlockTimestamp", [customTimestamp]);

      await socialMediaPlatform.connect(user1).createPost(EXAMPLE_CAPTION, EXAMPLE_IMG_HASH);
    });

    describe("Adding comment", function () {
      it("Should add a comment", async function () {

      });
    });
  });
});