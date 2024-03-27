// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @title dForce's whitelists module
 * @author dForce engineer
 */
abstract contract Whitelists {
	using EnumerableSet for EnumerableSet.AddressSet;

	/// @dev EnumerableSet of whitelists
	EnumerableSet.AddressSet internal whitelists_;

	/**
	 * @dev Emitted when `account` is added as `whitelists`.
	 */
	event WhitelistAdded(address account);

	/**
	 * @dev Emitted when `account` is removed from `whitelists`.
	 */
	event WhitelistRemoved(address account);

	/**
	 * @dev Throws if called by any account other than the whitelists.
	 */
	modifier onlyWhitelist() {
		require(isWhitelist(msg.sender), "onlyWhitelist: caller is not in the whitelist");
		_;
	}

	/**
	 * @notice Add `account` into whitelists.
	 * If `account` have not been a account, emits a `WhitelistAdded` event.
	 *
	 * @param _account The account to add
	 */
	function _addWhitelistInternal(address _account) internal virtual {
		require(_account != address(0), "_addWhitelistInternal: _account the zero address");
		require(whitelists_.add(_account), "_addWhitelistInternal: _account has been added");
		emit WhitelistAdded(_account);
	}

	/**
	 * @notice Remove `account` from whitelists.
	 * If `account` is a account, emits a `WhitelistRemoved` event.
	 *
	 * @param _account The account to remove
	 */
	function _removeWhitelistInternal(address _account) internal virtual {
		require(whitelists_.remove(_account), "_removeWhitelistInternal: _account has been removed");
		emit WhitelistRemoved(_account);
	}

	/**
	 * @notice Return all whitelists
	 * @return _whitelists The list of account addresses
	 */
	function whitelists() public view returns (address[] memory _whitelists) {
		_whitelists = whitelists_.values();
	}

	/**
	 * @dev Check if address is account
	 * @param _account The address to check
	 * @return Is account boolean, true: is the account; false: not the account
	 */
	function isWhitelist(address _account) public view virtual returns (bool) {
		return whitelists_.contains(_account);
	}
}
