// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/**
 * @title BasicTwiiter
 * @dev A simple smart contract that basic twitter
 * @custom:dev-run-script ./scripts/deploy_basic_twitter_with_ethers.ts
 */
contract BasicTwitter {
    struct Comment {
        address commenter;
        string content;
        uint256 timestamp;
    }

    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 countLikes;
        uint256 countComments;
    }

    mapping(uint256 => address[]) public tweetLikers;
    mapping(uint256 => Comment[]) public tweetComments;
    mapping(address => Tweet[]) public userTweets;
    Tweet[] public allTweets;

    uint16 public MIN_TWEET_LENGTH = 10;
    uint16 public MAX_TWEET_LENGTH = 256;
    address public owner;

    event TweetCreated(
        uint256 id,
        address author,
        string content,
        uint256 timestamp
    );
    event TweetLiked(uint256 id, address liker);
    event TweetUnliked(uint256 id, address unliker);
    event TweetCommented(
        uint256 id,
        address commenter,
        string comment,
        uint256 timestamp
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyAllowedAddress(address _allowedAddress) {
        require(
            msg.sender == _allowedAddress,
            "This address is not allowed to call."
        );
        _;
    }

    modifier verifiedNewMaxLength(uint16 newMaxLength) {
        require(
            newMaxLength > MIN_TWEET_LENGTH,
            "New max length of tweet needs to be longer than the min length."
        );
        _;
    }

    function incrementAmountLikes(uint256 _index) internal {
        allTweets[_index].countLikes++;
        tweetLikers[allTweets[_index].id].push(msg.sender);
    }

    function getTweet(uint256 _index) public view returns (Tweet memory) {
        return allTweets[_index];
    }

    function changeMaxTweetLength(uint16 newMaxLength)
        external
        onlyAllowedAddress(owner)
        verifiedNewMaxLength(newMaxLength)
    {
        MAX_TWEET_LENGTH = newMaxLength;
    }

    function getAllTweets() public view returns (Tweet[] memory) {
        return allTweets;
    }

    function getTweetsByAddress(address _ownerAddress)
        public
        view
        returns (Tweet[] memory)
    {
        return userTweets[_ownerAddress];
    }

    function getLikersOfTweet(uint256 _tweetId)
        public
        view
        returns (address[] memory)
    {
        return tweetLikers[_tweetId];
    }

    function getCommentsOfTweet(uint256 _tweetId)
        public
        view
        returns (Comment[] memory)
    {
        return tweetComments[_tweetId];
    }

    function createTweet(string memory _tweet) external {
        require(bytes(_tweet).length >= MIN_TWEET_LENGTH, "Tweet is too short");
        require(bytes(_tweet).length <= MAX_TWEET_LENGTH, "Tweet is too long");

        Tweet memory newTweet = Tweet({
            id: allTweets.length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            countLikes: 0,
            countComments: 0
        });

        allTweets.push(newTweet);
        userTweets[msg.sender].push(newTweet);
        emit TweetCreated(
            newTweet.id,
            newTweet.author,
            newTweet.content,
            newTweet.timestamp
        );
    }

    function likeTweet(uint256 _index) external {
        require(
            tweetLikers[allTweets[_index].id].length == 0 ||
                !isLikerOfTweet(_index, msg.sender),
            "Tweet already liked"
        );

        incrementAmountLikes(_index);
        emit TweetLiked(_index, msg.sender);
    }

    function unlikeTweet(uint256 _index) external {
        require(isLikerOfTweet(_index, msg.sender), "Tweet not yet liked");

        allTweets[_index].countLikes--;
        removeLikerFromTweet(_index, msg.sender);
        emit TweetUnliked(_index, msg.sender);
    }

    function commentOnTweet(uint256 _index, string memory _comment) external {
        require(bytes(_comment).length > 0, "Comment cannot be empty");

        Comment memory newComment = Comment({
            commenter: msg.sender,
            content: _comment,
            timestamp: block.timestamp
        });

        tweetComments[allTweets[_index].id].push(newComment);
        allTweets[_index].countComments++;
        emit TweetCommented(_index, msg.sender, _comment, block.timestamp);
    }

    function isLikerOfTweet(uint256 _index, address _liker)
        internal
        view
        returns (bool)
    {
        for (
            uint256 i = 0;
            i < tweetLikers[allTweets[_index].id].length;
            i++
        ) {
            if (tweetLikers[allTweets[_index].id][i] == _liker) {
                return true;
            }
        }
        return false;
    }

    function removeLikerFromTweet(uint256 _index, address _liker) internal {
        for (
            uint256 i = 0;
            i < tweetLikers[allTweets[_index].id].length;
            i++
        ) {
            if (tweetLikers[allTweets[_index].id][i] == _liker) {
                tweetLikers[allTweets[_index].id][i] = tweetLikers[
                    allTweets[_index].id
                ][tweetLikers[allTweets[_index].id].length - 1];
                tweetLikers[allTweets[_index].id].pop();
                break;
            }
        }
    }
}
