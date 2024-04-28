// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface ICommentManager{

    struct Comment {
        address author;
        string content;
        uint256 timestamp;
    }

    function _addComment(uint256, string memory, address) external;
    function _removeComment(uint256, uint256, address) external;
    function _getPostComments(uint256) external view returns(Comment[] memory);
    function _getComment(uint256, uint256) external view returns(Comment memory);
}