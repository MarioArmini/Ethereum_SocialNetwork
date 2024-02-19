// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract SocialMediaPlatform {

    struct Post {
        address author;
        string caption;
        string imageUrl;
        uint256 likes;
        uint256 commentsCount;
        mapping(uint256 => string) comments;
        bool flagged;
        address[] reporters;
    }

    mapping(uint256 => Post) public posts;
    uint256 public nextPostId = 1;

    event PostCreated(uint256 postId, address author, string caption, string imageUrl);
    event PostLiked(uint256 postId, address liker);
    event CommentAdded(uint256 postId, address commenter, string comment);
    event PostReported(uint256 postId, address reporter);
    event PostModerated(uint256 postId);

    modifier onlyModerator() {
        _;
    }

    function createPost(string memory _caption, string memory _imageUrl) external {

        Post storage newPost = posts[nextPostId];

        newPost.author = msg.sender;
        newPost.caption = _caption;
        newPost.imageUrl = _imageUrl;
        newPost.likes = 0;
        newPost.commentsCount = 0;
        newPost.flagged = false;

        emit PostCreated(nextPostId, msg.sender, _caption, _imageUrl);
        nextPostId++;
    }

    function likePost(uint256 _postId) external {
        require(_postId > 0 && _postId < nextPostId, "Invalid post ID");
        Post storage post = posts[_postId];
        post.likes++;
        emit PostLiked(_postId, msg.sender);
    }

    function addComment(uint256 _postId, string memory _comment) external {
        require(_postId > 0 && _postId < nextPostId, "Invalid post ID");
        Post storage post = posts[_postId];
        post.commentsCount++;
        post.comments[post.commentsCount] = _comment;
        emit CommentAdded(_postId, msg.sender, _comment);
    }

    function reportPost(uint256 _postId) external {
        require(_postId > 0 && _postId < nextPostId, "Invalid post ID");
        Post storage post = posts[_postId];
        if (!post.flagged){
            post.flagged = true;
        }
        post.reporters.push(msg.sender);

        emit PostReported(_postId, msg.sender);
    }

    function moderatePost(uint256 _postId) external onlyModerator {
        require(_postId > 0 && _postId < nextPostId, "Invalid post ID");
        Post storage post = posts[_postId];
        require(post.flagged, "Post not flagged");

        // Aggiungi qui la logica per moderare il post (eliminazione, avvertimento, ecc.)
        // ...

        emit PostModerated(_postId);
    }
}
