// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/VotingContract.sol";  // Adjust the import path based on your project structure

contract VotingTest is Test {
    Voting voting;
    address member1;
    address member2;
    address member3;

    function setUp() public {
    member1 = address(0x1);
    member2 = address(0x2);
    member3 = address(0x3);

    // Use memory array to pass members to the contract
    address;
_members[0] = member2;
_members[1] = member3;
    voting = new Voting(_members);  // Assuming the constructor takes an array of addresses
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

    // Member1 votes "yes"
    vm.startPrank(member1);
    voting.castVote(0, true);  // Vote "yes"
    vm.stopPrank();

    // Now execute the proposal
    vm.startPrank(member2);
    voting.executeProposal(0);  // Execute the proposal
    vm.stopPrank();

    // Check that the proposal has been executed
    (, , , , bool executedExecuted) = voting.proposals(0);
    assertTrue(executedExecuted);
}

// Dummy function to be executed by the proposal
function dummyFunction() public pure returns (bool) {
    return true;
}

}
