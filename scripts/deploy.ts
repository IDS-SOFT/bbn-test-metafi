
import { ethers } from "hardhat";

const tokenAddress = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199";
const interestRate = 5; //Percent
const minCollateralRatio = 10; //Percent

async function main() {

  const deploy_contract = await ethers.deployContract("MetaFiLendingPlatform", [tokenAddress, interestRate, minCollateralRatio]);

  await deploy_contract.waitForDeployment();

  console.log("MetaFiLendingPlatform is deployed to : ",await deploy_contract.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
