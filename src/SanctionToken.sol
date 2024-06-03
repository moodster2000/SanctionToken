// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title SanctionToken
 * @dev ERC20 token contract with administrative control to ban/unban addresses from transferring tokens.
 */
contract SanctionToken is ERC20, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    mapping(address => bool) private _bannedAddresses;

    /**
     * @dev Emitted when an address is banned.
     * @param account The address that was banned.
     */
    event AddressBanned(address indexed account);

    /**
     * @dev Emitted when an address is unbanned.
     * @param account The address that was unbanned.
     */
    event AddressUnbanned(address indexed account);

    /**
     * @notice Constructor that grants the deployer the admin roles and mints the initial supply of tokens.
     * @param initialSupply The initial supply of tokens to be minted.
     */
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Modifier to check if the account is banned.
     * @param account The address to check.
     */
    modifier notBanned(address account) {
        require(!_bannedAddresses[account], "Account is banned");
        _;
    }

    /**
     * @notice Ban an address from transferring tokens.
     * @param account The address to ban.
     */
    function banAddress(address account) public onlyRole(ADMIN_ROLE) {
        _bannedAddresses[account] = true;
        emit AddressBanned(account);
    }

    /**
     * @notice Unban an address, allowing it to transfer tokens again.
     * @param account The address to unban.
     */
    function unbanAddress(address account) public onlyRole(ADMIN_ROLE) {
        _bannedAddresses[account] = false;
        emit AddressUnbanned(account);
    }

    /**
     * @notice Check if an address is banned.
     * @param account The address to check.
     * @return True if the address is banned, false otherwise.
     */
    function isBanned(address account) public view returns (bool) {
        return _bannedAddresses[account];
    }

    /**
     * @dev Overridden internal function to include the notBanned modifier, ensuring banned addresses cannot transfer tokens.
     * @param from The address sending the tokens.
     * @param to The address receiving the tokens.
     * @param amount The amount of tokens being transferred.
     */
    function _update(address from, address to, uint256 amount)
        internal
        virtual
        override
        notBanned(from)
        notBanned(to)
    {
        super._update(from, to, amount);
    }
}
