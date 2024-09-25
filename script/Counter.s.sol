// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Voting} from "../src/VotingContract.sol";

contract VotingScript is Script {
    Voting public voting;
    address[]  members;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        voting = new Voting(members);

        vm.stopBroadcast();
    }
}
