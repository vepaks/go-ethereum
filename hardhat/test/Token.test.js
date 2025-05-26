const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token", function () {
  let Token;
  let token;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    // Get the Contract Factory
    Token = await ethers.getContractFactory("Token");
    
    // Get signers (accounts)
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    
    // Deploy the contract
    token = await Token.deploy();
    await token.deployed();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await token.owner()).to.equal(owner.address);
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const ownerBalance = await token.balanceOf(owner.address);
      expect(await token.totalSupply()).to.equal(ownerBalance);
    });

    it("Should have correct initial supply", async function () {
      const expectedSupply = ethers.utils.parseEther("1000000");
      expect(await token.totalSupply()).to.equal(expectedSupply);
    });
  });

  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      // Transfer 50 tokens from owner to addr1
      const transferAmount = ethers.utils.parseEther("50");
      await token.transfer(addr1.address, transferAmount);
      
      // Check balances
      const addr1Balance = await token.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(transferAmount);
      
      // Transfer 50 tokens from addr1 to addr2
      await token.connect(addr1).transfer(addr2.address, transferAmount);
      
      // Check final balances
      const addr2Balance = await token.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(transferAmount);
      expect(await token.balanceOf(addr1.address)).to.equal(0);
    });

    it("Should fail if sender doesn't have enough tokens", async function () {
      const initialOwnerBalance = await token.balanceOf(owner.address);
      
      // Try to send more tokens than available
      await expect(
        token.connect(addr1).transfer(owner.address, 1)
      ).to.be.revertedWith("ERC20: transfer amount exceeds balance");

      // Owner balance shouldn't have changed
      expect(await token.balanceOf(owner.address)).to.equal(initialOwnerBalance);
    });
  });

  describe("Minting", function () {
    it("Should allow only owner to mint new tokens", async function () {
      const mintAmount = ethers.utils.parseEther("1000");
      
      // Owner mints tokens to addr1
      await token.mint(addr1.address, mintAmount);
      expect(await token.balanceOf(addr1.address)).to.equal(mintAmount);
      
      // Non-owner tries to mint (should revert)
      await expect(
        token.connect(addr1).mint(addr2.address, mintAmount)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });

  describe("Burning", function () {
    it("Should allow users to burn their tokens", async function () {
      const transferAmount = ethers.utils.parseEther("100");
      const burnAmount = ethers.utils.parseEther("40");
      
      // Transfer some tokens to addr1
      await token.transfer(addr1.address, transferAmount);
      
      // Addr1 burns part of their tokens
      await token.connect(addr1).burn(burnAmount);
      
      // Check balance after burning
      expect(await token.balanceOf(addr1.address)).to.equal(transferAmount.sub(burnAmount));
      
      // Total supply should have decreased
      const expectedSupply = ethers.utils.parseEther("1000000").sub(burnAmount);
      expect(await token.totalSupply()).to.equal(expectedSupply);
    });
  });
});