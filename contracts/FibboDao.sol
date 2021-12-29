// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Libraries.sol";

contract FibboDao {
    address public teamWallet;
    IERC20 public token;
    bool private tokenAvailable = false;
    uint256 public minBalance;
    uint256 numRequests;
    mapping (uint256 => Request) public requests;
    uint32 public voteTime = 1 weeks; // TODO: Revisar

    struct Request{
        string description;
        uint256 value;
        address recipient;
        bool complete;
        uint256 voteEnding;
        uint256 votesCount;
        uint256 forVotes;
        uint256 againstVotes;
        mapping(address => bool) voted;
        bool success;
    }

    constructor(address _teamWallet, uint256 _minBalance) {
        teamWallet = _teamWallet;
        minBalance = _minBalance;
    }

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == teamWallet, 'You must be the owner.');
        _;
    }

    /**
     * @notice Function that updates the contract token.
     * @param _token Token contract address.
     */
    function setToken(IERC20 _token) public onlyOwner {
        require(!tokenAvailable, "Token is already inserted.");
        token = _token;
        tokenAvailable = true;
    }

    /**
     * @notice Allows the owner to create proposals.
     * @param _description Description of the application.
     * @param _recipient Address which will receive the tokens.
     */
    function createRequest(string memory _description, address _recipient) public onlyOwner {
        Request storage r = requests[numRequests++];
        r.description = _description;
        r.value = token.balanceOf(address(this));
        r.recipient = _recipient;
        r.complete = false;
        r.voteEnding = block.timestamp + voteTime;
        r.votesCount = 0;
        r.forVotes = 0;
        r.againstVotes = 0;
    }

    /**
     * @notice Function enabling investors to vote for the proposal.
     * @param _index Proposal ID.
     * @param _support Proposal support: true or false.
     */
    function voteRequest(uint32 _index, bool _support) public {
        uint256 _investorBalance = token.balanceOf(msg.sender);
        require(_investorBalance >= minBalance, "You must have enough balance.");
        Request storage request = requests[_index];
        require(block.timestamp <= request.voteEnding, "You can't vote now.");
        require(!request.voted[msg.sender], "You can't vote again.");

        request.voted[msg.sender] = true; // Mark this user as having already voted in this proposal.
        request.votesCount++; // Increase the number of votes in the proposal.

        if(_support) {
            request.forVotes++;
        } else {
            request.againstVotes++;
        }
    }

    /**
     * @notice End and execute the proposal.
     * @param _index Proposal ID.
     */
    function executeRequest(uint32 _index) public onlyOwner {
        Request storage request = requests[_index];
        require(block.timestamp > request.voteEnding, "You can't finalize now.");
        require(!request.complete, "The request has finished.");

        if(request.forVotes > request.againstVotes) {
            request.success = true;
            
            token.transfer(request.recipient, request.value);
        } else {
            request.success = false;
        }

        request.complete = true;
    }
}