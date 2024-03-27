//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IController {
	function priceOracle() external view returns (address);

	function markets(address _iToken) external view returns (uint256, uint256, uint256, uint256, bool, bool, bool);
}

interface IPriceOracle {
	function getUnderlyingPrice(address _iToken) external returns (uint256);

	function getUnderlyingPriceAndStatus(address _iToken) external returns (uint256, bool);
}

interface IiToken is IERC20 {
	function symbol() external view returns (string memory);

	function isSupported() external view returns (bool);

	function isiToken() external view returns (bool);

	function underlying() external view returns (address);

	function controller() external view returns (address);

	function exchangeRateCurrent() external returns (uint256);

	function getCash() external view returns (uint256);

	function balanceOfUnderlying(address _account) external returns (uint256);

	function mint(address _recipient, uint256 _mintAmount) external;

	function redeem(address _from, uint256 _redeemTokens) external;

	function redeemUnderlying(address _from, uint256 _redeemAmount) external;
}

interface IiETH {
	function symbol() external view returns (string memory);

	function isSupported() external view returns (bool);

	function isiToken() external view returns (bool);

	function underlying() external view returns (address);

	function controller() external view returns (address);

	function exchangeRateCurrent() external returns (uint256);

	function getCash() external view returns (uint256);

	function balanceOfUnderlying(address _account) external returns (uint256);

	function mint(address _recipient) external payable;

	function redeem(address _from, uint256 _redeemTokens) external;

	function redeemUnderlying(address _from, uint256 _redeemAmount) external;
}
