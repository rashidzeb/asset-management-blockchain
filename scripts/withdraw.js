const { getNamedAccounts, ethers } = require("hardhat");

async function main() {
  const { deployer } = await getNamedAccounts();
  const Pool = await ethers.getContract("Pool", deployer);
  console.log("withdrawing....");
  const transactionResponse = await Pool.withdraw();
  await transactionResponse.wait(1);
  console.log("withdrawn!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
