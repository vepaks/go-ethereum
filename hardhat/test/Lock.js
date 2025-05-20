const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Lock", function () {
  let lock;
  let owner;
  let otherAccount;
  let snapshotId;

  beforeEach(async function () {
    // Take a snapshot before each test
    snapshotId = await ethers.provider.send("evm_snapshot", []);
    // Get signers
    [owner, otherAccount] = await ethers.getSigners();

    // Deploy contract
    const Lock = await ethers.getContractFactory("Lock");
    const unlockTime = Math.floor(Date.now() / 1000) + 60; // 1 minute from now
    lock = await Lock.deploy(unlockTime, { value: ethers.parseEther("1.0") });
  });

  afterEach(async function () {
    // Restore to snapshot after each test
    await ethers.provider.send("evm_revert", [snapshotId]);
  });

  describe("Deployment", function () {
    it("Should set the right unlockTime", async function () {
      const currentTime = Math.floor(Date.now() / 1000);
      const unlockTime = await lock.unlockTime();
      expect(unlockTime).to.be.gt(currentTime);
    });

    it("Should set the right owner", async function () {
      expect(await lock.owner()).to.equal(owner.address);
    });

    it("Should receive and store the funds to lock", async function () {
      expect(await ethers.provider.getBalance(lock.target)).to.equal(
        ethers.parseEther("1.0")
      );
    });
  });

  describe("Withdrawals", function () {
    it("Should revert with the right error if called too soon", async function () {
      await expect(lock.withdraw()).to.be.revertedWith("You can't withdraw yet");
    });

    it("Should revert with the right error if called from another account", async function () {
      // Increase time to well past unlock time
      await ethers.provider.send("evm_increaseTime", [120]);
      await ethers.provider.send("evm_mine");
      await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
        "You aren't the owner"
      );
    });

    it("Should transfer the funds to the owner", async function () {
      // Increase time to well past unlock time
      await ethers.provider.send("evm_increaseTime", [120]);
      await ethers.provider.send("evm_mine");

      const initialBalance = await ethers.provider.getBalance(owner.address);
      const tx = await lock.withdraw();
      const receipt = await tx.wait();
      const finalBalance = await ethers.provider.getBalance(owner.address);

      // Проверяваме, че балансът се е увеличил (минус gas fee)
      expect(finalBalance).to.be.gt(initialBalance);
    });
  });
}); 