import {
    time,
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

    describe("Post management", function () {

      const EXAMPLE_IMG_HASH = "0x7B502C3A1F48C8609AE212CDFB639DEE39673F5E";
      const EXAMPLE_CAPTION = "This is a caption example";
      const BAD_EXAMPLE_CAPTION = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies";
      const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

      const customTimestamp = Math.floor(Date.now() / 1000) + 60; // 60 seconds into the future =)

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
      });

      describe("Get post", function () {
        it("Should get post", async function () {
          const { socialMediaPlatform, user1 } = await loadFixture(deploySocialMediaPlatform);

          await ethers.provider.send("evm_setNextBlockTimestamp", [customTimestamp]);
          
          await socialMediaPlatform.connect(user1).createPost(EXAMPLE_CAPTION, EXAMPLE_IMG_HASH);

          await expect(socialMediaPlatform.getPost(1)).not.to.be.reverted;
           
          const [
            author,
            caption,
            imageUrlIPFSHash,
            likes,
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
    });
});