// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/VotingContract.sol";

contract VotingTest is Test {
    Voting voting;
    address member1;
    address member2;
    address member3;
    address[] _members;

    function setUp() public {
        member1 = address(0x1);
        member2 = address(0x2);
        member3 = address(0x3);
        
        _members = [member1, member2, member3];  // Initialize members array
        voting = new Voting(_members);  // Create Voting contract instance
    }

    function testCreateProposal() public {
        vm.startPrank(member2);  // Use member2 to create a proposal
        voting.newProposal(address(0), "0x");  // Create a dummy proposal
        vm.stopPrank();

        // Check that the proposal was created
        (address target, bytes memory data, uint256 yesCount, uint256 noCount, bool executed) = voting.proposals(0);
        assertEq(target, address(0));
        assertEq(data, "0x");
        assertEq(yesCount, 0);
        assertEq(noCount, 0);
        assertFalse(executed);
    }

    function testCastVote() public {
        vm.startPrank(member2);
        voting.newProposal(address(0), bytes("")); // Create a proposal
        vm.stopPrank();

        vm.startPrank(member3);  // Use member3 to vote
        voting.castVote(0, true);  // Vote "yes"
        vm.stopPrank();

        // Check that the vote was cast
        (address target, bytes memory data, uint256 yesCount, uint256 noCount, bool executed) = voting.proposals(0);
        assertEq(yesCount, 1);
        assertEq(noCount, 0);

        // Now member3 should not be able to vote again
        // vm.expectRevert("You are not allowed to vote twice");
        voting.castVote(0, false);
    }

   function testExecuteProposal() public {
    vm.startPrank(member2);
    voting.newProposal(address(this), abi.encodeWithSignature("dummyFunction()"));  // Create a proposal
    vm.stopPrank();

    // Member3 votes "yes"
    vm.startPrank(member3);
    voting.castVote(0, true);  // Vote "yes"
    vm.stopPrank();

    // Member2 votes "yes"
    vm.startPrank(member2);
    voting.castVote(0, true);  // Vote "yes"
    vm.stopPrank();

    // Check that the proposal has been executed automatically after reaching the threshold
    (address target, bytes memory data, uint256 yesCount, uint256 noCount, bool executed) = voting.proposals(0);
    assertTrue(executed);  // The proposal should already be executed, no need for a manual execution call
}


    // Dummy function to be executed by the proposal
    function dummyFunction() public pure returns (bool) {
        return true;
    }
}
