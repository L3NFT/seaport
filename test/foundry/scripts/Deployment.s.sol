// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {Seaport} from "../../../contracts/Seaport.sol";
import {ConduitController} from "../../../contracts/conduit/ConduitController.sol";


import "forge-std/Test.sol";

contract Deployment is Test {
  Seaport seaport;
  ConduitController controller;

  function run() public {
    vm.startBroadcast();

    controller = new ConduitController();
    seaport = new Seaport(address(controller));

    vm.stopBroadcast();
  }
}