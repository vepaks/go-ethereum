const { expect } = require("chai");

describe("Token", function() {
  let token;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function() {
    [owner, addr1, addr2] = await ethers.getSigners();
    
    // Deploy token contract
    const Token = await ethers.getContractFactory("Token");
    token = await Token.deploy();
    await token.deployed();
  });

  describe("Deployment", function() {
    it("Should assign total supply to owner", async function() {
      const ownerBalance = await token.balanceOf(owner.address);
      expect(await token.totalSupply()).to.equal(ownerBalance);
    });
    
    it("Should set the right owner", async function() {
      expect(await token.owner()).to.equal(owner.address);
    });
  });

  describe("Transactions", function() {
    it("Should transfer tokens between accounts", async function() {
      // Transfer 50 tokens from owner to addr1
      await token.transfer(addr1.address, 50);
      const addr1Balance = await token.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(50);

      // Transfer 50 tokens from addr1 to addr2
      await token.connect(addr1).transfer(addr2.address, 50);
      const addr2Balance = await token.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(50);
    });

    it("Should fail if sender doesn't have enough tokens", async function() {
      const initialOwnerBalance = await token.balanceOf(owner.address);
      
      // Try to send more tokens than available
      await expect(
        token.connect(addr1).transfer(owner.address, 1)
      ).to.be.reverted;

      // Owner balance shouldn't have changed
      expect(await token.balanceOf(owner.address)).to.equal(initialOwnerBalance);
    });
  });

  describe("Token operations", function() {
    it("Should allow owner to mint tokens", async function() {
      await token.mint(addr1.address, 100);
      expect(await token.balanceOf(addr1.address)).to.equal(100);
    });

    it("Should not allow non-owner to mint tokens", async function() {
      await expect(
        token.connect(addr1).mint(addr2.address, 100)
      ).to.be.reverted;
    });

    it("Should allow users to burn their tokens", async function() {
      await token.transfer(addr1.address, 100);
      await token.connect(addr1).burn(50);
      expect(await token.balanceOf(addr1.address)).to.equal(50);
    });
  });
});