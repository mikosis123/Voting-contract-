// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
        mapping(address => bool) hasVoted; 
        mapping(address => bool) vote;     
    }
    event ProposalCreated (uint proID );
    event VoteCast(uint proID,address voters);
    Proposal[] public proposals;
    
   
    function newProposal(address proposal, bytes memory data) external {
        Proposal storage newProposal = proposals.push();
        newProposal.target = proposal;
        newProposal.data = data;
        emit ProposalCreated(proposals.length-1);
    }


    function castVote(uint proID, bool vote) external {
        require(proID < proposals.length, "Proposal does not exist");  // Corrected ID check
        
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

        // Update the voter's vote record
        selectedProposal.hasVoted[msg.sender] = true;
        selectedProposal.vote[msg.sender] = vote;
        emit VoteCast(proID,msg.sender);
    }
}
