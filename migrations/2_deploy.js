// migrations/2_deploy.js
const Lottery = artifacts.require('Lottery');

module.exports = async function (deployer) {
  await deployer.deploy(Lottery);
};