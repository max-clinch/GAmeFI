const { ethers } = require('hardhat');

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

deployContracts();
