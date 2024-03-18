// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/SignedMath.sol";

contract SocialMediaPlatform {
    using SignedMath for uint256;

    uint256 constant MAX_CAPTION_LENGTH = 500;
    uint256 constant MAX_COMMENT_LENGTH = 500;
    uint256 constant MAX_USER_REPORTS = 5;
    uint256 public nextPostId = 1;
    uint256 public nextCommentId = 1;

    address _owner;

    struct Post {
        address author;
        string caption;
        string imageUrlIPFSHash;
        uint256 likes;
        address[] supporters;
        uint256 commentsCount;
        mapping(uint256 => Comment) comments;
        bool flagged;
        address[] reporters;
        bool isVisible;
        address moderatorAgent;
        uint256 timeStamp;
        uint256 latestChangesTimeStamp;
        mapping(address => uint256) userReports;
    }

    struct Comment {
        address author;
        string content;
    }

    // MAPPINGS
    mapping(uint256 => Post) public _posts;
    mapping(address => bool) public _moderators;

    // EVENTS
    event PostCreated(
        uint256 postId,
        address author,
        string caption,
        string imageUrlIPFSHash
    );
    event PostModified(
        uint256 postId,
        address author,
        string caption,
        string imageUrlIPFSHash
    );
    event PostDeleted(uint256 postId);
    event PostLiked(uint256 postId, address supporter);
    event PostUnliked(uint256 postId, address supporter);
    event CommentAdded(uint256 postId, address commenter, string comment);
    event CommentRemoved(uint256 postId, address commenter, uint256 commentId);
    event PostReported(uint256 postId, address reporter);
    event PostRemoved(uint256 postId);

    modifier onlyOwner() {
        require(_owner == msg.sender, "Not authorized");
        _;
    }

    modifier onlyModerator() {
        require(_moderators[msg.sender], "Not authorized");
        _;
    }

    constructor(address owner) {
        _owner = owner;
    }

    function createPost(
        string memory caption,
        string memory imageUrlIPFSHash
    ) external {
        require(msg.sender != address(0), "Author cannot be zero address");
        require(
            bytes(caption).length <= MAX_CAPTION_LENGTH,
            "Caption exceeds maximum length"
        );

        Post storage newPost = _posts[nextPostId];

        newPost.author = msg.sender;
        newPost.caption = caption;
        newPost.imageUrlIPFSHash = imageUrlIPFSHash;
        newPost.likes = 0;
        newPost.commentsCount = 0;
        newPost.flagged = false;
        newPost.isVisible = true;
        newPost.timeStamp = block.timestamp;
        newPost.latestChangesTimeStamp = block.timestamp;

        emit PostCreated(nextPostId, msg.sender, caption, imageUrlIPFSHash);
        nextPostId++;
    }

    function editPost(
        string memory caption,
        string memory imageUrlIPFSHash,
        uint256 postId
    ) external {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        require(msg.sender != address(0), "Author cannot be zero address");
        require(
            bytes(caption).length <= MAX_CAPTION_LENGTH,
            "Caption exceeds maximum length"
        );

        Post storage post = _posts[postId];

        require(post.author == msg.sender, "Sender must be the Author");

        post.author = msg.sender;
        post.caption = caption;
        post.imageUrlIPFSHash = imageUrlIPFSHash;
        post.latestChangesTimeStamp = block.timestamp;

        emit PostModified(postId, msg.sender, caption, imageUrlIPFSHash);
    }

    function deletePost(uint256 postId) external {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        require(msg.sender != address(0), "Author cannot be zero address");

        Post storage post = _posts[postId];

        require(post.author == msg.sender, "Sender must be the Author");

        post.isVisible = false;

        emit PostDeleted(postId);
    }

    function likePost(uint256 postId) external {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        require(msg.sender != address(0), "Sender cannot be zero address");

        Post storage post = _posts[postId];
        post.supporters.push(msg.sender);
        post.likes++;

        emit PostLiked(postId, msg.sender);
    }

    function removeLike(uint256 postId) external {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        require(msg.sender != address(0), "Sender cannot be zero address");

        Post storage post = _posts[postId];

        removeElement(post.supporters, msg.sender);
        post.likes--;

        emit PostUnliked(postId, msg.sender);
    }

    function addComment(uint256 postId, string memory comment) external {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        require(
            bytes(comment).length <= MAX_COMMENT_LENGTH,
            "Comment exceeds maximum length"
        );
        Post storage post = _posts[postId];

        require(post.isVisible, "Post is not visible");

        post.commentsCount++;
        post.comments[post.commentsCount] = Comment(msg.sender, comment);
        emit CommentAdded(postId, msg.sender, comment);
    }

    function removeComment(uint256 postId, uint256 commentId) external {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        
        Post storage post = _posts[postId];

        require(commentId > 0 && commentId <= post.commentsCount, "Invalid comment ID");
        require(post.isVisible, "Post is not visible");
        require(post.comments[commentId].author == msg.sender, "Only comment author can remove comment");

        post.comments[commentId] = post.comments[post.commentsCount];
        delete post.comments[post.commentsCount];
        post.commentsCount--;

        emit CommentRemoved(postId, msg.sender, commentId);
    }

    function reportPost(uint256 postId) external {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        Post storage post = _posts[postId];

        require(
            post.userReports[msg.sender] <= MAX_USER_REPORTS,
            "Max report number already reached"
        );

        if (!post.flagged) {
            post.flagged = true;
        }

        post.reporters.push(msg.sender);
        post.userReports[msg.sender]++;

        emit PostReported(postId, msg.sender);
    }

    function removePost(uint256 postId) external onlyModerator {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        Post storage post = _posts[postId];
        require(post.flagged, "Post not flagged");

        post.isVisible = false;
        post.moderatorAgent = msg.sender;

        emit PostRemoved(postId);
    }

    function getPost(
        uint256 postId
    )
        public
        view
        returns (
            address,
            string memory,
            string memory,
            uint256,
            address[] memory,
            uint256,
            bool,
            address[] memory,
            bool,
            address,
            uint256,
            uint256
        )
    {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        Post storage post = _posts[postId];

        require(post.isVisible, "Post is not visible");

        return (
            post.author,
            post.caption,
            post.imageUrlIPFSHash,
            post.likes,
            post.supporters,
            post.commentsCount,
            post.flagged,
            post.reporters,
            post.isVisible,
            post.moderatorAgent,
            post.timeStamp,
            post.latestChangesTimeStamp
        );
    }

    function getPostComments(
        uint256 postId
    ) public view returns (address[] memory, string[] memory) {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        Post storage post = _posts[postId];

        require(post.isVisible, "Post is not visible");

        address[] memory authors = new address[](post.commentsCount);
        string[] memory comments = new string[](post.commentsCount);
        for (uint256 i = 1; i <= post.commentsCount; i++) {
            authors[i - 1] = post.comments[i].author;
            comments[i - 1] = post.comments[i].content;
        }

        return (authors, comments);
    }

    //Moderators methods
    function addModerator(address moderator) external onlyOwner {
        require(moderator != address(0), "Cannot add zero address");
        _moderators[moderator] = true;
    }

    function removeModerator(address moderator) external onlyOwner {
        require(_moderators[moderator], "Address is not a moderator");
        _moderators[moderator] = false;
    }

    // Utils
    function removeElement(address[] storage array, address addr) private {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == addr) {
                array[i] = array[array.length - 1];
                array.pop();
                return;
            }
        }
    }
}
