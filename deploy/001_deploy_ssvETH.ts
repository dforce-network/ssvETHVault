import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
	const {deployer} = await hre.getNamedAccounts();
	console.log('Deployer address is: ', deployer);

	const {deploy} = hre.deployments;
	const useProxy = !hre.network.live;
	const saETH = '0x92a38d33007896DbE401eF1Ac4986D811874C8B7';

	await deploy('ProxyAdmin', {
		from: deployer,
		contract: 'ProxyAdmin2Step',
		args: [],
		log: true,
		skipIfAlreadyDeployed: true,
	});

	// proxy only in non-live network (localhost and hardhat network) enabling HCR (Hot Contract Replacement)
	// in live network, proxy is disabled and constructor is invoked
	await deploy('ssvETH', {
		from: deployer,
		args: [saETH],
		proxy: {
			owner: deployer,
			proxyContract: 'TransparentUpgradeableProxy',
			viaAdminContract: {name: 'ProxyAdmin'},
			execute: {
				init: {
					methodName: 'initialize',
					args: ['dForce ssvETH', 'ssvETH'],
				},
			},
		},
		log: true,
		autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
	});

	return !useProxy; // when live network, record the script as executed to prevent rexecution
};
export default func;
func.id = 'deploy_ssvETH'; // id required to prevent reexecution
func.tags = ['ssvETH'];
