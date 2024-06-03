// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SanctionToken.sol";

contract SanctionTokenTest is Test {
    SanctionToken token;
    address admin = address(1);
    address user1 = address(2);
    address user2 = address(3);
    address bannedUser = address(4);

    function setUp() public {
        vm.prank(admin);
        token = new SanctionToken(1000);    
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), 1000);
        assertEq(token.balanceOf(admin), 1000);
    }

    function testTransfer() public {
        vm.prank(admin);
        token.transfer(user1, 100);
        assertEq(token.balanceOf(user1), 100);
    }

    function testBanAddress() public {
        vm.prank(admin);
        token.banAddress(user1);
        assertTrue(token.isBanned(user1));
    }

    function testUnbanAddress() public {
        vm.startPrank(admin);
        token.banAddress(user1);
        token.unbanAddress(user1);
        vm.stopPrank();
        assertFalse(token.isBanned(user1));
    }

    function testBannedCannotTransfer() public {
        vm.startPrank(admin);
        token.transfer(bannedUser, 100);
        token.banAddress(bannedUser);
        vm.stopPrank();

        vm.prank(bannedUser);
        vm.expectRevert("Account is banned");
        token.transfer(user1, 10);
    }

    function testTransferToBanned() public {
        vm.startPrank(admin);
        token.banAddress(bannedUser);
        vm.expectRevert("Account is banned");
        token.transfer(bannedUser, 10);
    }
}
