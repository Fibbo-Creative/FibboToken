// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

// Imports
import "./Libraries.sol";

contract Vesting is ReentrancyGuard {
    address public owner; // Owner address.
    IERC20 public token; // Token Contract.
    address public foundersWallet; // Founders wallet.
    uint256 public foundersBalance = 15000000000000000000000000; // 15 millions
    address public teamWallet; // Team wallet.
    uint256 public teamBalance = 10000000000000000000000000; // 10 millions
    uint public cooldownTime = 30 days; // Cooldown time you will have the claim.
    uint public claimReady; // Saves the time in which the user can make the next claim.
    uint8 public month; // Monthly count.

    constructor(address _foundersWallet, address _teamWallet) {
        owner = msg.sender;
        foundersWallet = _foundersWallet;
        teamWallet = _teamWallet;

        month = 0;
    }

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, 'You must be the owner.');
        _;
    }

    // Modifiers
    modifier onlyFoundersOrTeam() {
        require(msg.sender == foundersWallet || msg.sender == teamWallet, 'You must be founder or team/advisor member.');
        _;
    }

    /**
     * @notice Function that updates the contract token.
     * @param _token Token contract address.
     */
    function setToken(IERC20 _token) public onlyOwner {
        token = _token;
    }

    /**
     * @notice Calculate the percentage of a number.
     * @param x Number.
     * @param y Percentage of number.
     * @param scale Division.
     */
    function mulScale (uint x, uint y, uint128 scale) internal pure returns (uint) {
        uint a = x / scale;
        uint b = x % scale;
        uint c = y / scale;
        uint d = y % scale;

        return a * c * scale + a * d + b * c + b * d / scale;
    }

    function claimTokens() public onlyFoundersOrTeam nonReentrant {
        require(claimReady <= block.timestamp, "You can't claim now.");
        require(token.balanceOf(address(this)) > 0, "Insufficient Balance.");

        uint16 percentage;
        if(month == 24) {
            percentage = 455; // 455 basis points = 4,55%
        } else {
            percentage = 415; // 415 basis points = 4,15%
        }

        uint _withdrawableBalance;
        if(msg.sender == foundersWallet) {
            _withdrawableBalance = mulScale(foundersBalance, percentage, 10000);
        } else {
            _withdrawableBalance = mulScale(teamBalance, percentage, 10000);
        }

        claimReady = block.timestamp + cooldownTime;
        month++;
        token.transfer(teamWallet, _withdrawableBalance);
    }
}