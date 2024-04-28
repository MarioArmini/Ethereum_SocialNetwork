// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/SignedMath.sol";
import "./CommentManager.sol";
import "./interfaces/ICommentManager.sol";
import "./interfaces/IReportingManager.sol";

contract SocialMediaPlatform {
    using SignedMath for uint256;

    uint256 constant MAX_CAPTION_LENGTH = 500;
    uint256 constant MAX_COMMENT_LENGTH = 500;
    uint256 public nextPostId = 1;

    address _owner;
    ICommentManager public _icommentManager;
    IReportingManager public _ireportingManager;

    struct Post {
        address author;
        string caption;
        string imageUrlIPFSHash;
        uint256 likes;
        address[] supporters;
        uint256 commentsCount;
        bool flagged;
        address[] reporters;
        bool isVisible;
        uint256 timeStamp;
        uint256 latestChangesTimeStamp;
    }

    // MAPPINGS
    mapping(uint256 => Post) public _posts;

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
    event ModeratorAdded(address moderator);
    event ModeratorRemoved(address moderator);

    modifier onlyOwner() {
        require(_owner == msg.sender, "Not authorized");
        _;
    }

    modifier onlyModerator() {
        require(_ireportingManager._isModerator(msg.sender), "Not authorized");
        _;
    }

    constructor(
        address owner,
        address commentManagerAddress,
        address reportingManagerAddress) {
        _owner = owner;
        _icommentManager = ICommentManager(commentManagerAddress);
        _ireportingManager = IReportingManager(reportingManagerAddress);

        _icommentManager._setOwner(owner);
        _ireportingManager._setOwner(owner);
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

        Post storage post = _posts[postId];

        require(post.isVisible, "Post is not visible");

        _icommentManager._addComment(postId, comment, msg.sender);

        post.commentsCount++;

        emit CommentAdded(postId, msg.sender, comment);
    }

    function removeComment(uint256 postId, uint256 commentId) external {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        
        Post storage post = _posts[postId];

        require(post.isVisible, "Post is not visible");

        _icommentManager._removeComment(postId, commentId, msg.sender);

        post.commentsCount--;

        emit CommentRemoved(postId, msg.sender, commentId);
    }

    function reportPost(uint256 postId) external {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        Post storage post = _posts[postId];
        
        require(post.isVisible, "Post is not visible");

        if (!post.flagged) {
            post.flagged = true;
        }

        post.reporters.push(msg.sender);

        emit PostReported(postId, msg.sender);
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
            post.timeStamp,
            post.latestChangesTimeStamp
        );
    }

    function getPostReportsInfo(
        uint256 postId
    )
        public
        view
        returns (
            address,
            string memory,
            string memory,
            bool,
            address[] memory,
            bool,
            uint256
        )
    {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        Post storage post = _posts[postId];

        return (
            post.author,
            post.caption,
            post.imageUrlIPFSHash,
            post.flagged,
            post.reporters,
            post.isVisible,
            post.timeStamp
        );
    }

    function getPostComments(
        uint256 postId
    ) public view returns (ICommentManager.Comment[] memory) {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        Post storage post = _posts[postId];

        require(post.isVisible, "Post is not visible");

        ICommentManager.Comment[] memory comments = _icommentManager._getPostComments(postId);
        return comments;
    }

    function getPostComment(
        uint256 postId,
        uint256 commentId
    ) public view returns (ICommentManager.Comment memory) {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        Post storage post = _posts[postId];

        require(post.isVisible, "Post is not visible");

        return _icommentManager._getComment(postId, commentId);
    }

    //Moderators methods
    function addModerator(address moderator) external onlyOwner {
        _ireportingManager._addModerator(moderator);
    }

    function removeModerator(address moderator) external onlyOwner {
        _ireportingManager._removeModerator(moderator);
    }

    function removePost(uint256 postId) external onlyModerator {
        require(postId > 0 && postId < nextPostId, "Invalid post ID");
        Post storage post = _posts[postId];
        require(post.flagged, "Post is not flagged");
        require(post.isVisible, "Post is not visible");

        post.isVisible = false;

        emit PostRemoved(postId);
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
