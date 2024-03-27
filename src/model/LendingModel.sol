//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "../interface/ILending.sol";

/**
 * @title Lending Model Contract
 * @notice Abstract contract for lending operations
 * @dev Contains functions for setting internal lending parameters and getting underlying price
 * @author dForce engineer
 */
abstract contract LendingModel {
	IiToken internal iToken_;

	/**
	 * @dev Sets the internal lending parameters for the given iToken.
	 * @param _iToken The iToken to set as the internal lending parameter.
	 */
	function _setLendingInternal(IiToken _iToken) internal virtual {
		require(_iToken.isiToken(), "_setLendingInternal: _iToken is invalid");
		iToken_ = _iToken;
	}

	/**
	 * @dev Retrieves the underlying price of the iToken.
	 * @return The underlying price of the iToken.
	 */
	function _getUnderlyingPrice() internal returns (uint256) {
		(uint256 _price, bool _isPriceValid) = IPriceOracle(IController(iToken_.controller()).priceOracle())
			.getUnderlyingPriceAndStatus(address(iToken_));
		require(_price > 0 && _isPriceValid, "getUnderlyingPrice: price is invalid");
		return _price;
	}
	/**
	 * @dev Returns the available cash (liquidity) in the pool.
	 * @return The amount of available cash in the pool.
	 */
	function lendingCash() external view returns (uint256) {
		return iToken_.getCash();
	}

	/**
	 * @dev Returns the remaining deposit limit of the pool.
	 */
	function limitOfDeposit() external returns (uint256 _depositLimit) {
		(, , , uint256 _supplyCapacity, , , ) = IController(iToken_.controller()).markets(address(iToken_));

		uint256 _totalUnderlying = (iToken_.totalSupply() * iToken_.exchangeRateCurrent()) / 1 ether;

		if (_supplyCapacity > _totalUnderlying) _depositLimit = _supplyCapacity - _totalUnderlying;
	}

	/**
	 * @dev Returns the deposit status of the pool.
	 */
	function depositStatus() external view returns (bool _mintPaused) {
		(, , , , _mintPaused, , ) = IController(iToken_.controller()).markets(address(iToken_));
	}

	/**
	 * @dev Returns the withdraw status of the pool.
	 */
	function withdrawStatus() external view returns (bool _redeemPaused) {
		(, , , , , _redeemPaused, ) = IController(iToken_.controller()).markets(address(iToken_));
	}

	function getUnderlyingPrice() external returns (uint256) {
		return _getUnderlyingPrice();
	}

	/**
	 * @dev Returns the underlying asset of the pool.
	 */
	function iToken() external view returns (IiToken) {
		return iToken_;
	}
}
