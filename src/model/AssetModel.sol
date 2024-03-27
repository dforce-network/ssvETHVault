//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Asset Model Contract
 * @notice This contract defines the basic structure for asset models.
 * @dev Abstract contract defining the Asset Model.
 * @author dForce engineer
 */
abstract contract AssetModel {
	/**
	 * @dev The internal immutable IERC20 ASSET token.
	 */
	IERC20 internal immutable ASSET;

	/**
	 * @dev Constructor to set the ASSET token.
	 * @param _asset The IERC20 token to be set as ASSET.
	 */
	constructor(IERC20 _asset) {
		ASSET = _asset;
	}

	/**
	 * @dev Calculates the amount of Ether to input based on the given asset amount.
	 * @param _assetAmount The amount of the asset to convert to Ether.
	 * @return _ethAmount The calculated amount of Ether to input.
	 */
	function _calcIutputEth(uint256 _assetAmount) internal view virtual returns (uint256 _ethAmount) {
		uint256 _ethExchangeRate = _exchangeRate();
		_ethAmount = ((_assetAmount * 1 ether) + (_ethExchangeRate - 1)) / _ethExchangeRate;
	}

	/**
	 * @dev Calculates the amount of Ether to output based on the given asset amount.
	 * @param _assetAmount The amount of the asset to convert from Ether.
	 * @return _ethAmount The calculated amount of Ether to output.
	 */
	function _calcOutputEth(uint256 _assetAmount) internal view virtual returns (uint256 _ethAmount) {
		_ethAmount = (_assetAmount * 1 ether) / _exchangeRate();
	}

	/**
	 * @dev Calculates the amount of asset to input based on the given Ether amount.
	 * @param _ethAmount The amount of Ether to convert to asset.
	 * @return _assetAmount The calculated amount of asset to input.
	 */
	function _calcIutputAsset(uint256 _ethAmount) internal view virtual returns (uint256 _assetAmount) {
		_assetAmount = ((_ethAmount * _exchangeRate()) + (1 ether - 1)) / 1 ether;
	}

	/**
	 * @dev Calculates the amount of asset to output based on the given Ether amount.
	 * @param _ethAmount The amount of Ether to convert from asset.
	 * @return _assetAmount The calculated amount of asset to output.
	 */
	function _calcOutputAsset(uint256 _ethAmount) internal view virtual returns (uint256 _assetAmount) {
		_assetAmount = (_ethAmount * _exchangeRate()) / 1 ether;
	}

	/**
	 * @dev Retrieves the exchange rate between asset and Ether.
	 * @return The current exchange rate.
	 */
	function _exchangeRate() internal view virtual returns (uint256);

	/**
	 * @dev Internal function to retrieve the amount of asset consumed.
	 */
	function _assetConsumedInternal() internal view virtual returns (uint256);

	/**
	 * @dev Internal function to calculate the remaining asset quota available for consumption.
	 * @return _assetQuota The remaining asset quota.
	 */
	function _assetQuotaInternal() internal view virtual returns (uint256 _assetQuota) {
		uint256 _assetAmount = ASSET.balanceOf(address(this));
		uint256 _consumed = _assetConsumedInternal();
		if (_assetAmount > _consumed) _assetQuota = _assetAmount - _consumed;
	}

	/**
	 * @dev External function to get the amount of Ether to input based on the given asset amount.
	 * @param _assetAmount The amount of the asset to convert to Ether.
	 * @return _ethAmount The calculated amount of Ether to input.
	 */
	function getIutputEth(uint256 _assetAmount) external view returns (uint256 _ethAmount) {
		_ethAmount = _calcIutputEth(_assetAmount);
	}

	/**
	 * @dev External function to get the amount of Ether to output based on the given asset amount.
	 * @param _assetAmount The amount of the asset to convert from Ether.
	 * @return _ethAmount The calculated amount of Ether to output.
	 */
	function getOutputEth(uint256 _assetAmount) external view returns (uint256 _ethAmount) {
		_ethAmount = _calcOutputEth(_assetAmount);
	}

	/**
	 * @dev External function to get the amount of asset to input based on the given Ether amount.
	 * @param _ethAmount The amount of Ether to convert to asset.
	 * @return _assetAmount The calculated amount of asset to input.
	 */
	function getIutputAsset(uint256 _ethAmount) external view returns (uint256 _assetAmount) {
		_assetAmount = _calcIutputAsset(_ethAmount);
	}

	/**
	 * @dev External function to get the amount of asset to output based on the given Ether amount.
	 * @param _ethAmount The amount of Ether to convert to asset.
	 * @return _assetAmount The calculated amount of asset to output.
	 */
	function getOutputAsset(uint256 _ethAmount) external view returns (uint256 _assetAmount) {
		_assetAmount = _calcOutputAsset(_ethAmount);
	}

	/**
	 * @dev External function to retrieve the exchange rate between asset and Ether.
	 * @return The current exchange rate.
	 */
	function exchangeRate() external view returns (uint256) {
		return _exchangeRate();
	}

	/**
	 * @dev External function to retrieve the amount of asset consumed.
	 * @return The amount of asset consumed.
	 */
	function assetConsumed() external view returns (uint256) {
		return _assetConsumedInternal();
	}

	/**
	 * @dev External function to retrieve the remaining asset quota available for consumption.
	 * @return _assetQuota The remaining asset quota.
	 */
	function assetQuota() external view returns (uint256) {
		return _assetQuotaInternal();
	}

	/**
	 * @dev External function to retrieve the total amount of the asset held by the contract.
	 * @return The total amount of the asset held by the contract.
	 */
	function totalAsset() external view returns (uint256) {
		return ASSET.balanceOf(address(this));
	}

	/**
	 * @dev External function to retrieve the asset token address.
	 * @return The asset token address.
	 */
	function asset() external view returns (IERC20) {
		return ASSET;
	}
}
