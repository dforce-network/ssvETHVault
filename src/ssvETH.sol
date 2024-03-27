// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts/interfaces/IERC4626.sol";

import "./library/Whitelists.sol";
import "./model/AssetModel.sol";
import "./model/LendingModel.sol";

/**
 * @title ssvETH
 * @notice Implements functionality for ssvETH token.
 * @dev Contains the main logic for ssvETH token functionality.
 * @author dForce engineer
 */
contract ssvETH is
	Ownable2StepUpgradeable,
	PausableUpgradeable,
	ERC20PermitUpgradeable,
	Whitelists,
	AssetModel,
	LendingModel
{
	using Address for address;
	using SafeERC20 for IERC20;

	/**
	 * @dev Constructor function for ssvETH token.
	 * @param _asset The underlying asset for the ssvETH token.
	 */
	constructor(IERC20 _asset) AssetModel(_asset) {
		_disableInitializers();
	}

	/**
	 * @dev Fallback function to receive Ether.
	 */
	receive() external payable {}

	/**
	 * @notice Initializes the ssvETH token with the provided name and symbol.
	 * @dev Initializes the contract with required initializations for Ownable, Pausable, ERC20, and ERC20 Permit.
	 */
	function initialize(string memory _name, string memory _symbol) external initializer {
		__Ownable2Step_init();
		__Pausable_init();
		__ERC20_init(_name, _symbol);
		__ERC20Permit_init(_name);
	}

	/**
	 * @dev Unpauses the contract.
	 * @notice This function can only be called by the contract owner.
	 */
	function _open() external onlyOwner {
		_unpause();
	}

	/**
	 * @dev Pauses the contract.
	 * @notice This function can only be called by the pause guardian.
	 */
	function _close() external onlyOwner {
		_pause();
	}

	/**
	 * @dev Add a new account into the whitelist.
	 */
	function _addWhitelist(address _account) external onlyOwner {
		_addWhitelistInternal(_account);
	}

	/**
	 * @dev Remove an exist account from the whitelist.
	 */
	function _removeWhitelist(address _account) external onlyOwner {
		_removeWhitelistInternal(_account);
	}

	/**
	 * @dev Sets the lending parameters for the contract.
	 * @param _iToken The iToken to be set for lending.
	 * @notice Only the contract owner can call this function.
	 */
	function _setLending(IiToken _iToken) external onlyOwner {
		require(_iToken.underlying() == address(this), "_setLending: underlying address must be this contract");
		_setLendingInternal(_iToken);
	}

	/**
	 * @dev Claims ETH and transfers it to the specified address.
	 * @param _to The address to receive the ETH.
	 * @param _ethAmount The amount of ETH to claim.
	 * @notice Only addresses in the whitelist can call this function.
	 */
	function claimETH(address _to, uint256 _ethAmount) external onlyWhitelist {
		_to.functionCallWithValue("", _ethAmount, "claimETH: Transfer ETH reverted.");
	}

	/**
	 * @dev Hook that is called before any token transfer.
	 * @param from The address where the tokens are transferred from.
	 * @param to The address where the tokens are transferred to.
	 * @param amount The amount of tokens being transferred.
	 */
	function _beforeTokenTransfer(address from, address to, uint256 amount) internal override whenNotPaused {}

	/**
	 * @dev Returns the exchange rate of the asset.
	 */
	function _exchangeRate() internal view override returns (uint256) {
		return IERC4626(address(ASSET)).convertToAssets(1 ether);
	}

	/**
	 * @dev Returns the total amount of assets consumed internally.
	 */
	function _assetConsumedInternal() internal view override returns (uint256) {
		return totalSupply();
	}

	/**
	 * @dev Wraps ETH into assets and mints the corresponding amount of assets to the specified address.
	 * @param _to The address to receive the minted assets.
	 * @param _ethAmount The amount of ETH to wrap.
	 * @return The amount of assets minted.
	 */
	function _wrap(address _to, uint256 _ethAmount) internal returns (uint256) {
		uint256 _amount = _calcOutputAsset(_ethAmount);
		require(_amount >= _assetQuotaInternal(), "_wrap: insufficient asset quota");
		_mint(_to, _amount);
		return _amount;
	}

	/**
	 * @dev Burns assets from the specified address and transfers them to another address.
	 * @param _from The address to burn assets from.
	 * @param _to The address to receive the assets.
	 * @param _amount The amount of assets to burn and transfer.
	 */
	function _unwrapToAsset(address _from, address _to, uint256 _amount) internal {
		_burn(_from, _amount);
		ASSET.safeTransfer(_to, _amount);
	}

	/**
	 * @dev Deposits tokens to the iToken contract by approving the transfer and minting the specified amount to the target address.
	 * @param _to The address to receive the minted tokens.
	 * @param _amount The amount of tokens to mint.
	 */
	function _deposit(address _to, uint256 _amount) internal {
		_approve(address(this), address(iToken_), _amount);
		iToken_.mint(_to, _amount);
	}

	/**
	 * @dev Wraps ETH into assets and returns the corresponding amount of assets to the sender.
	 */
	function wrap() external payable returns (uint256) {
		return _wrap(msg.sender, msg.value);
	}

	/**
	 * @dev Wraps ETH into assets and returns the corresponding amount of assets to the specified address.
	 * @param _to The address to receive the wrapped assets.
	 */
	function wrap(address _to) external payable returns (uint256) {
		return _wrap(_to, msg.value);
	}

	/**
	 * @dev Wraps ETH into assets, mints the corresponding amount of assets to the contract, and deposits them to the sender.
	 */
	function wrapAndDeposit() external payable returns (uint256 _amount) {
		_amount = _wrap(address(this), msg.value);
		_deposit(msg.sender, _amount);
	}

	/**
	 * @dev Wraps ETH into assets, mints the corresponding amount of assets to the contract, and deposits them to the specified address.
	 * @param _to The address to receive the minted assets.
	 */
	function wrapAndDeposit(address _to) external payable returns (uint256 _amount) {
		_amount = _wrap(address(this), msg.value);
		_deposit(_to, _amount);
	}

	/**
	 * @dev Unwraps assets to the specified amount and transfers them to the sender.
	 * @param _amount The amount of assets to unwrap and transfer.
	 */
	function unwrapToAsset(uint256 _amount) external {
		_unwrapToAsset(msg.sender, msg.sender, _amount);
	}

	/**
	 * @dev Unwraps assets to the specified amount and transfers them to the specified address.
	 * @param _to The address to receive the unwrapped assets.
	 * @param _amount The amount of assets to unwrap and transfer.
	 */
	function unwrapToAsset(address _to, uint256 _amount) external {
		_unwrapToAsset(msg.sender, _to, _amount);
	}

	/**
	 * @dev Redeems underlying assets and unwraps them to the specified amount, transferring them to the sender.
	 * @param _amount The amount of underlying assets to redeem and unwrap.
	 */
	function withdrawUnderlyingAndUnwrapToAsset(uint256 _amount) external {
		iToken_.redeemUnderlying(msg.sender, _amount);
		_unwrapToAsset(address(this), msg.sender, _amount);
	}

	/**
	 * @dev Redeems underlying assets and unwraps them to the specified amount, transferring them to the specified address.
	 * @param _to The address to receive the unwrapped assets.
	 * @param _amount The amount of underlying assets to redeem and unwrap.
	 */
	function withdrawUnderlyingAndUnwrapToAsset(address _to, uint256 _amount) external {
		iToken_.redeemUnderlying(msg.sender, _amount);
		_unwrapToAsset(address(this), _to, _amount);
	}

	/**
	 * @dev Redeems iToken assets and unwraps them to the corresponding amount, transferring them to the sender.
	 * @param _iTokenAmount The amount of iToken assets to redeem and unwrap.
	 */
	function withdrawAndUnwrapToAsset(uint256 _iTokenAmount) external {
		uint256 _balance = balanceOf(address(this));

		iToken_.redeem(msg.sender, _iTokenAmount);

		_unwrapToAsset(address(this), msg.sender, balanceOf(address(this)) - _balance);
	}

	/**
	 * @dev Redeems iToken assets and unwraps them to the corresponding amount, transferring them to the specified address.
	 * @param _to The address to receive the unwrapped assets.
	 * @param _iTokenAmount The amount of iToken assets to redeem and unwrap.
	 */
	function withdrawAndUnwrapToAsset(address _to, uint256 _iTokenAmount) external {
		uint256 _balance = balanceOf(address(this));

		iToken_.redeem(msg.sender, _iTokenAmount);

		_unwrapToAsset(address(this), _to, balanceOf(address(this)) - _balance);
	}

	/**
	 * @dev Checks if the account is whitelisted.
	 * @param _account The address to check.
	 * @return True if the account is whitelisted, false otherwise.
	 */
	function isWhitelist(address _account) public view override returns (bool) {
		return Whitelists.isWhitelist(_account) || _account == owner();
	}
}
