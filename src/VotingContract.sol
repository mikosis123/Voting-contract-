// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
        mapping(address => bool) hasVoted;  // Track if user has voted
        mapping(address => bool) vote;      // Track user's vote: true = yes, false = no
    }

    address public owner;  // The deployer of the contract
    mapping(address => bool) public members;  // Addresses allowed to create proposals and vote

    event ProposalCreated(uint proID);
    event VoteCast(uint proID, address voter);

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

    
    function newProposal(address proposal, bytes memory data) external onlyMember {
        Proposal storage newProposal = proposals.push();
        newProposal.target = proposal;
        newProposal.data = data;
        emit ProposalCreated(proposals.length - 1);
    }


    function castVote(uint proID, bool vote) external onlyMember {
        require(proID < proposals.length, "Proposal does not exist");  

        Proposal storage selectedProposal = proposals[proID]; 

       
        if (selectedProposal.hasVoted[msg.sender]) {
           
            if (selectedProposal.vote[msg.sender]) {
                selectedProposal.yesCount--; 
            } else {
                selectedProposal.noCount--;  
            }
        }

  
        if (vote) {
            selectedProposal.yesCount++;  
        } else {
            selectedProposal.noCount++;   
        }

     
        selectedProposal.hasVoted[msg.sender] = true;
        selectedProposal.vote[msg.sender] = vote;

       
        emit VoteCast(proID, msg.sender);
    }
}

