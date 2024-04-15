// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/**
 * @title BasicTwiiter
 * @dev A simple smart contract that basic twitter
 * @custom:dev-run-script ./scripts/deploy_basic_twitter_with_ethers.ts
 */
contract BasicTwitter {
    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 amountViews;
    }
    uint16 public MIN_TWEET_LENGTH = 10;
    uint16 public MAX_TWEET_LENGTH = 256;
    address public owner;
    mapping(address => Tweet[]) public tweets;

    constructor() {
        owner = msg.sender;
    }

    event TweetCreated(
        uint256 id,
        address author,
        string content,
        uint256 timestamp
    );

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
            "New max length of tweet need longer min length."
        );
        _;
    }

    function incrementAmountViews(address _owner, uint256 _index)
        internal
        returns (Tweet memory)
    {
        tweets[_owner][_index].amountViews++;
        return tweets[_owner][_index];
    }

    function getTweet(address _owner, uint256 _index)
        public
        returns (Tweet memory)
    {
        Tweet[] memory ownerTweets = getTweetsByAddress(_owner);
        Tweet memory tweet = ownerTweets[_index];
        if (msg.sender != tweet.author)
            return incrementAmountViews(_owner, _index);
        return tweet;
    }

    function changeMaxTweetLenth(uint16 newMaxLength)
        external
        onlyAllowedAddress(owner)
        verifiedNewMaxLength(newMaxLength)
    {
        MAX_TWEET_LENGTH = newMaxLength;
    }

    function getTweetsByAddress(address _ownerAddress)
        public
        view
        returns (Tweet[] memory)
    {
        return tweets[_ownerAddress];
    }

    function getMyTweets() external view returns (Tweet[] memory) {
        return getTweetsByAddress(msg.sender);
    }

    function getMyTweet(uint256 index) external returns (Tweet memory) {
        return getTweet(msg.sender, index);
    }

    function createTweet(string memory _tweet) external {
        require(bytes(_tweet).length >= MIN_TWEET_LENGTH, "Tweet is to short");
        require(bytes(_tweet).length <= MAX_TWEET_LENGTH, "Tweet is to long");
        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            amountViews: 0
        });

        tweets[msg.sender].push(newTweet);
        emit TweetCreated(
            newTweet.id,
            newTweet.author,
            newTweet.content,
            newTweet.timestamp
        );
    }
}
