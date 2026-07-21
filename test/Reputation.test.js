const { expect } = require("chai");

describe("Reputation", function () {
  let reputation;
  let owner;
  let traveler;

  beforeEach(async function () {
    [owner, traveler] = await ethers.getSigners();

    const Reputation =
      await ethers.getContractFactory("Reputation");

    reputation = await Reputation.deploy();

    await reputation.waitForDeployment();
  });

  it("Should record a completed delivery", async function () {
    await reputation.recordDelivery(traveler.address);

    const data =
      await reputation.getReputation(traveler.address);

    expect(data.completedDeliveries).to.equal(1);
  });

  it("Should add a rating", async function () {
    await reputation.addRating(
      traveler.address,
      5
    );

    const data =
      await reputation.getReputation(traveler.address);

    expect(data.averageRating).to.equal(5);
  });

  it("Should calculate average rating", async function () {
    await reputation.addRating(
      traveler.address,
      5
    );

    await reputation.addRating(
      traveler.address,
      4
    );

    const average =
      await reputation.getAverageRating(
        traveler.address
      );

    expect(average).to.equal(4);
  });
});
