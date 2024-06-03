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
        token = new SanctionToken(1000 ether); // Mint 1000 tokens to admin
        token.grantRole(token.ADMIN_ROLE(), admin);

        vm.deal(admin, 1 ether);
        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);
        vm.deal(bannedUser, 1 ether);
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), 1000 ether);
        assertEq(token.balanceOf(admin), 1000 ether);
    }

    function testTransfer() public {
        vm.prank(admin);
        token.transfer(user1, 100 ether);
        assertEq(token.balanceOf(user1), 100 ether);
    }

    function testBanAddress() public {
        vm.prank(admin);
        token.banAddress(user1);
        assertTrue(token.isBanned(user1));
    }

    function testUnbanAddress() public {
        vm.prank(admin);
        token.banAddress(user1);
        token.unbanAddress(user1);
        assertFalse(token.isBanned(user1));
    }

    function testBannedCannotTransfer() public {
        vm.prank(admin);
        token.banAddress(bannedUser);

        vm.prank(admin);
        token.transfer(bannedUser, 100 ether);

        vm.prank(bannedUser);
        vm.expectRevert("Account is banned");
        token.transfer(user1, 10 ether);
    }

    function testTransferToBanned() public {
        vm.prank(admin);
        token.banAddress(bannedUser);

        vm.prank(admin);
        vm.expectRevert("Account is banned");
        token.transfer(bannedUser, 10 ether);
    }
}
