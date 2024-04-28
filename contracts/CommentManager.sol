// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/SignedMath.sol";

contract CommentManager {
    using SignedMath for uint256;

    uint256 constant MAX_COMMENT_LENGTH = 500;

    struct Comment {
        address author;
        string content;
        uint256 timestamp;
    }

    mapping(uint256 => Comment[]) public postComments;

    function _addComment(
        uint256 postId,
        string memory comment,
        address author
    ) external {
        require(bytes(comment).length > 0, "Comment cannot be empty");
        require(
            bytes(comment).length <= MAX_COMMENT_LENGTH,
            "Comment exceeds maximum length"
        );

        Comment memory newComment = Comment(author, comment, block.timestamp);

        postComments[postId].push(newComment);
    }

    function _removeComment(
        uint256 postId,
        uint256 commentId,
        address sender
    ) external {
        require(commentId <= postComments[postId].length, "Invalid comment Id");

        Comment[] storage comments = postComments[postId];
        require(
            comments[commentId].author == sender,
            "You can only remove your own comments"
        );

        if (commentId == comments.length - 1) {
            comments.pop();
        } 
        else {
            comments[commentId] = comments[comments.length - 1];
            comments.pop();
        }
    }

    function _getComment(
        uint256 postId,
        uint256 coommentId
    ) external view returns (Comment memory) {
        Comment[] memory comments = postComments[postId];
        Comment memory comment = comments[coommentId];

        return comment;
    }

    function _getPostComments(
        uint256 postId
    ) external view returns (Comment[] memory) {
        return postComments[postId];
    }
}
