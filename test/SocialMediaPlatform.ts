import {
    time,
    loadFixture,
  } from "@nomicfoundation/hardhat-toolbox/network-helpers";
  import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
  import { expect } from "chai";
  import { ethers } from "hardhat";
  
  describe("Lock", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deploySocialMediaPlatform() {

      // Contracts are deployed using the first signer/account by default
      const [owner, moderator1, moderator2, user] = await ethers.getSigners();
  
      const SocialMediaPlatform = await ethers.getContractFactory("SocialMediaPlatform");
      const socialMediaPlatform = await SocialMediaPlatform.deploy(owner.address);
  
      return { socialMediaPlatform, owner, moderator1, moderator2, user };
    }

    

});