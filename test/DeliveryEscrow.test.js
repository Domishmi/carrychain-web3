const { expect } = require("chai");

describe("DeliveryEscrow", function () {
  let escrow;
  let sender;
  let traveler;
  let receiver;

  beforeEach(async function () {
    [sender, traveler, receiver] =
      await ethers.getSigners();

    const DeliveryEscrow =
      await ethers.getContractFactory(
        "DeliveryEscrow"
      );

    escrow = await DeliveryEscrow.deploy();

    await escrow.waitForDeployment();
  });

  it("Should create a delivery", async function () {
    const reward =
      ethers.parseEther("1");

    await escrow
      .connect(sender)
      .createDelivery(
        receiver.address,
        "Mumbai",
        "Ahmedabad",
        { value: reward }
      );

    const delivery =
      await escrow.getDelivery(0);

    expect(delivery.sender)
      .to.equal(sender.address);

    expect(delivery.receiver)
      .to.equal(receiver.address);

    expect(delivery.reward)
      .to.equal(reward);

    expect(delivery.status)
      .to.equal(0);
  });

  it("Should allow a traveler to accept a delivery", async function () {
    const reward =
      ethers.parseEther("1");

    await escrow
      .connect(sender)
      .createDelivery(
        receiver.address,
        "Mumbai",
        "Ahmedabad",
        { value: reward }
      );

    await escrow
      .connect(traveler)
      .acceptDelivery(0);

    const delivery =
      await escrow.getDelivery(0);

    expect(delivery.traveler)
      .to.equal(traveler.address);

    expect(delivery.status)
      .to.equal(1);
  });

  it("Should complete delivery and pay the traveler", async function () {
    const reward =
      ethers.parseEther("1");

    await escrow
      .connect(sender)
      .createDelivery(
        receiver.address,
        "Mumbai",
        "Ahmedabad",
        { value: reward }
      );

    await escrow
      .connect(traveler)
      .acceptDelivery(0);

    const travelerBalanceBefore =
      await ethers.provider.getBalance(
        traveler.address
      );

    await escrow
      .connect(receiver)
      .confirmDelivery(0);

    const travelerBalanceAfter =
      await ethers.provider.getBalance(
        traveler.address
      );

    expect(
      travelerBalanceAfter - travelerBalanceBefore
    ).to.equal(reward);

    const delivery =
      await escrow.getDelivery(0);

    expect(delivery.status)
      .to.equal(3);
  });

  it("Should reject sender from becoming traveler", async function () {
    const reward =
      ethers.parseEther("1");

    await escrow
      .connect(sender)
      .createDelivery(
        receiver.address,
        "Mumbai",
        "Ahmedabad",
        { value: reward }
      );

    await expect(
      escrow
        .connect(sender)
        .acceptDelivery(0)
    ).to.be.revertedWith(
      "Sender cannot be traveler"
    );
  });

  it("Should reject confirmation from a non-receiver", async function () {
    const reward =
      ethers.parseEther("1");

    await escrow
      .connect(sender)
      .createDelivery(
        receiver.address,
        "Mumbai",
        "Ahmedabad",
        { value: reward }
      );

    await escrow
      .connect(traveler)
      .acceptDelivery(0);

    await expect(
      escrow
        .connect(sender)
        .confirmDelivery(0)
    ).to.be.revertedWith(
      "Only receiver can confirm delivery"
    );
  });
});
