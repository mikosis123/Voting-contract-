// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "./Voting.sol";  // Adjust the import path based on your project structure

contract VotingTest is Test {
    Voting voting;
    address member1;
    address member2;
    address member3;

    function setUp() public {
        member1 = address(0x1);
        member2 = address(0x2);
        member3 = address(0x3);

        // Deploy the Voting contract with two members
        address;
        members[0] = member2;
        members[1] = member3;
        voting = new Voting(members);
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
        voting.newProposal(address(0), "0x");  // Create a proposal
        vm.stopPrank();

        vm.startPrank(member3);  // Use member3 to vote
        voting.castVote(0, true);  // Vote "yes"
        vm.stopPrank();

        // Check that the vote was cast
        (address target, bytes memory data, uint256 yesCount, uint256 noCount, bool executed) = voting.proposals(0);
        assertEq(yesCount, 1);
        assertEq(noCount, 0);

        // Now member3 should not be able to vote again
        vm.expectRevert("You are not allowed to perform this action");
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

        // Check that the proposal has not been executed yet
        (address target, bytes memory data, uint256 yesCount, uint256 noCount, bool executed) = voting.proposals(0);
        assertFalse(executed);

        // Cast more votes to reach the minimum required
        vm.startPrank(member1);
        voting.castVote(0, true);  // Vote "yes"
        vm.stopPrank();

        // Now the proposal should be executed
        (bool success, ) = voting.proposals(0).target.call(voting.proposals(0).data);
        assertTrue(success);

        // Check that the proposal has been executed
        (address targetExecuted, bytes memory dataExecuted, uint256 yesCountExecuted, uint256 noCountExecuted, bool executedExecuted) = voting.proposals(0);
        assertTrue(executedExecuted);
    }
}
