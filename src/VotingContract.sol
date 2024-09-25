// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    struct Proposal {
        address target;  // Address to send the call to
        bytes data;      // Data to be sent in the call
        uint yesCount;   // Number of "yes" votes
        uint noCount;    // Number of "no" votes
        bool executed;   // Whether the proposal has been executed
        mapping(address => bool) hasVoted;  // Track if user has voted
        mapping(address => bool) vote;      // Track user's vote: true = yes, false = no
    }

    address public owner;  // The deployer of the contract
    mapping(address => bool) public members;  // Addresses allowed to create proposals and vote

    uint constant MINIMUM_YES_VOTES = 2;  // Minimum number of yes votes to execute proposal

    event ProposalCreated(uint proID);
    event VoteCast(uint proID, address voter);
    event ProposalExecuted(uint proID, bool success);

    Proposal[] public proposals;

    // Constructor: Takes an array of addresses as members and adds them to the members list
    constructor(address[] memory _members) {
        owner = msg.sender;  // The deployer is the owner
        members[owner] = true;  // Add the deployer as a member

        // Add the provided addresses as members
        for (uint i = 0; i < _members.length; i++) {
            members[_members[i]] = true;
        }
    }

    // Modifier to check if the caller is a member (or owner)
    modifier onlyMember() {
        require(members[msg.sender], "You are not allowed to perform this action");
        _;
    }

    // Function to create a new proposal (only members can do this)
    function newProposal(address proposal, bytes memory data) external onlyMember {
        Proposal storage newProposal = proposals.push();
        newProposal.target = proposal;
        newProposal.data = data;
        newProposal.executed = false;  // Set the proposal as not executed
        emit ProposalCreated(proposals.length - 1);
    }

    // Function to cast a vote (only members can vote)
    function castVote(uint proID, bool vote) external onlyMember {
        require(proID < proposals.length, "Proposal does not exist");  // Ensure proposal ID is valid

        Proposal storage selectedProposal = proposals[proID];  // Reference the selected proposal

        require(!selectedProposal.executed, "Proposal already executed");  // Ensure the proposal has not been executed

        // Check if the voter has already voted
        if (selectedProposal.hasVoted[msg.sender]) {
            // Decrease the count of the previous vote
            if (selectedProposal.vote[msg.sender]) {
                selectedProposal.yesCount--;  // Decrease yesCount if previous vote was yes
            } else {
                selectedProposal.noCount--;   // Decrease noCount if previous vote was no
            }
        }

        // Cast the new vote
        if (vote) {
            selectedProposal.yesCount++;  // Increment yesCount for a "yes" vote
        } else {
            selectedProposal.noCount++;   // Increment noCount for a "no" vote
        }

        // Update the voter's vote record
        selectedProposal.hasVoted[msg.sender] = true;
        selectedProposal.vote[msg.sender] = vote;

        // Emit vote cast event
        emit VoteCast(proID, msg.sender);

        // Check if the proposal has reached the threshold for execution
        if (selectedProposal.yesCount >= MINIMUM_YES_VOTES) {
            executeProposal(proID);
        }
    }

    // Internal function to execute the proposal when it meets the required number of votes
    function executeProposal(uint proID) public {
        Proposal storage selectedProposal = proposals[proID];

        // Ensure the proposal hasn't already been executed
        require(!selectedProposal.executed, "Proposal already executed");

        // Execute the proposal by calling the target with the provided data
        (bool success, ) = selectedProposal.target.call(selectedProposal.data);
        
        // Mark the proposal as executed
        selectedProposal.executed = true;

        // Emit an event to indicate the proposal was executed
        emit ProposalExecuted(proID, success);
    }
}
