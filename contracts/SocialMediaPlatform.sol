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
        bool isVisible;
        address moderatorAgent;
    }

    address _owner;
    mapping(uint256 => Post) public _posts;
    uint256 public nextPostId = 1;
    mapping(address => bool) public _isModerator;

    event PostCreated(uint256 postId, address author, string caption, string imageUrl);
    event PostLiked(uint256 postId, address liker);
    event CommentAdded(uint256 postId, address commenter, string comment);
    event PostReported(uint256 postId, address reporter);
    event PostModerated(uint256 postId);

    modifier onlyOwner() {
        require(_owner == msg.sender, "Not authorized");
        _;
    }

    modifier onlyModerator() {
        require(_isModerator[msg.sender], "Not authorized");
        _;
    }

    constructor(address owner) {
        _owner = owner;
    }

    function createPost(string memory caption, string memory imageUrl) external {
        Post storage newPost = _posts[nextPostId];

        newPost.author = msg.sender;
        newPost.caption = caption;
        newPost.imageUrl = imageUrl;
        newPost.likes = 0;
        newPost.commentsCount = 0;
        newPost.flagged = false;
        newPost.isVisible = true;

        emit PostCreated(nextPostId, msg.sender, caption, imageUrl);
        nextPostId++;
    }

    function likePost(uint256 postId) external {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        Post storage post = _posts[postId];
        post.likes++;
        emit PostLiked(postId, msg.sender);
    }

    function addComment(uint256 postId, string memory comment) external {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        Post storage post = _posts[postId];
        post.commentsCount++;
        post.comments[post.commentsCount] = comment;
        emit CommentAdded(postId, msg.sender, comment);
    }

    function reportPost(uint256 postId) external {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        Post storage post = _posts[postId];
        if (!post.flagged){
            post.flagged = true;
        }
        post.reporters.push(msg.sender);

        emit PostReported(postId, msg.sender);
    }

    function moderatePost(uint256 postId) external onlyModerator {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        Post storage post = _posts[postId];
        require(post.flagged, "Post not flagged");

        post.isVisible = false;
        post.moderatorAgent = msg.sender;

        emit PostModerated(postId);
    }

    //Moderators methods
    function addModerator(address moderator) external onlyOwner {
        require(moderator != address(0x0), "Cannot add zero address");
        _isModerator[moderator] = true;
    }

    function removeModerator(address moderator) external onlyOwner {
        require(_isModerator[moderator], "address is not a moderator");
        _isModerator[moderator] = false;
    }
}
