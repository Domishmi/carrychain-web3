const hre = require("hardhat");

async function main() {
  console.log("Deploying CarryChain contracts...");

  const usdcAddress =
    process.env.USDC_CONTRACT_ADDRESS;

  if (!usdcAddress) {
    throw new Error(
      "USDC_CONTRACT_ADDRESS is not set"
    );
  }

  const CarryToken =
    await hre.ethers.getContractFactory(
      "CarryToken"
    );

  const carryToken =
    await CarryToken.deploy();

  await carryToken.waitForDeployment();

  console.log(
    "CarryToken deployed to:",
    await carryToken.getAddress()
  );

  const Reputation =
    await hre.ethers.getContractFactory(
      "Reputation"
    );

  const reputation =
    await Reputation.deploy();

  await reputation.waitForDeployment();

  console.log(
    "Reputation deployed to:",
    await reputation.getAddress()
  );

  const DeliveryEscrow =
    await hre.ethers.getContractFactory(
      "DeliveryEscrow"
    );

  const deliveryEscrow =
    await DeliveryEscrow.deploy(
      usdcAddress
    );

  await deliveryEscrow.waitForDeployment();

  console.log(
    "DeliveryEscrow deployed to:",
    await deliveryEscrow.getAddress()
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
