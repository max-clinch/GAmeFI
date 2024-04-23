/*const { ethers } = require('hardhat');

function deployContracts() {
  // Deploy MiliToken
  ethers.getContractFactory("MiliToken")
    .then(function(factory) {
      return factory.deploy();
    })
    .then(function(miliToken) {
      console.log("MiliToken deployed to:", miliToken.address);

      // Deploy MillionaireGame
      return ethers.getContractFactory("MillionaireGame")
        .then(function(millionaireGameFactory) {
          return millionaireGameFactory.deploy(miliToken.address);
        })
        .then(function(millionaireGame) {
          console.log("MillionaireGame deployed to:", millionaireGame.address);
        });
    })
    .catch(function(error) {
      console.error(error);
      process.exit(1);
    });
}

deployContracts();*/

const { ethers } = require('hardhat');
const fs = require('fs');

async function deployContracts() {
  try {
    // Deploy MiliToken
    const miliTokenFactory = await ethers.getContractFactory("MiliToken");
    const miliToken = await miliTokenFactory.deploy();
    console.log("MiliToken deployed to:", miliToken.address);

    // Deploy MillionaireGame
    const millionaireGameFactory = await ethers.getContractFactory("MillionaireGame");
    const millionaireGame = await millionaireGameFactory.deploy(miliToken.address);
    console.log("MillionaireGame deployed to:", millionaireGame.address);

    // Write addresses to a file
    const addresses = {
      MiliToken: miliToken.address,
      MillionaireGame: millionaireGame.address
    };
    fs.writeFileSync('deployed-contracts.json', JSON.stringify(addresses, null, 2));
    console.log("Contract addresses written to deployed-contracts.json");
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

deployContracts();

