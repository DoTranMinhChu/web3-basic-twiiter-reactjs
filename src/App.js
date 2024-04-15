import React, { useState, useEffect } from "react";
import Web3 from "web3";
import BasicTwitterContract from "./smart-contracts/contracts/artifacts/BasicTwitter.json";
import "./App.css";
const contractAddress = "0xa838015C754cAE5b1880f88bB20860BFD06a0752"; // Replace with your contract address

function App() {
  const [web3, setWeb3] = useState(null);
  const [accounts, setAccounts] = useState([]);
  const [contract, setContract] = useState(null);
  const [tweets, setTweets] = useState([]);
  const [newTweetContent, setNewTweetContent] = useState("");
  const [newCommentContent, setNewCommentContent] = useState("");
  const [commentVisibility, setCommentVisibility] = useState({});

  useEffect(() => {
    const init = async () => {
      try {
        if (window.ethereum) {
          await window.ethereum.request({ method: "eth_requestAccounts" });
          const web3Instance = new Web3(window.ethereum);
          setWeb3(web3Instance);
          const accounts = await web3Instance.eth.getAccounts();
          setAccounts(accounts);
          const contractInstance = new web3Instance.eth.Contract(
            BasicTwitterContract.abi,
            contractAddress
          );
          setContract(contractInstance);
        } else {
          console.error("MetaMask extension not detected!");
        }
      } catch (error) {
        console.error(error);
      }
    };
    init();
  }, []);

  const fetchTweets = async () => {
    try {
      if (!contract || !web3) return;
      const fetchedTweets = await contract.methods
        .getAllTweets()
        .call({ from: accounts[0] });

      setTweets(fetchedTweets);
      setCommentVisibility(false);
    } catch (error) {
      console.error(error);
    }
  };

  useEffect(() => {
    if (contract && web3) {
      fetchTweets();
    }
  }, [contract, web3]);

  const createTweet = async () => {
    try {
      if (!contract || !web3) return;
      if (!newTweetContent) return;
      await contract.methods.createTweet(newTweetContent).send({
        from: accounts[0],
      });
      setNewTweetContent("");
      fetchTweets();
    } catch (error) {
      console.error(error);
    }
  };

  const handleChange = (event) => {
    setNewTweetContent(event.target.value);
  };
  const handleChangeNewCommentContent = (event) => {
    setNewCommentContent(event.target.value);
  };
  const toggleCommentVisibility = async (tweetId, index) => {
    try {
      if (!commentVisibility[index]) {
        await fetchComments(tweetId, index);
      }
      setCommentVisibility({
        ...commentVisibility,
        [index]: !commentVisibility[index],
      });
    } catch (error) {
      console.error(error);
    }
  };

  const fetchComments = async (tweetId, index) => {
    try {
      if (!contract || !web3) return;
      const comments = await contract.methods
        .getCommentsOfTweet(tweetId)
        .call({ from: accounts[0] });
      const updatedTweets = [...tweets];
      updatedTweets[index].comments = comments;
      setTweets(updatedTweets);
    } catch (error) {
      console.error(error);
    }
  };

  const likeTweet = async (tweetId) => {
    try {
      if (!contract || !web3) return;
      await contract.methods.likeTweet(tweetId).send({ from: accounts[0] });
      fetchTweets();
    } catch (error) {
      console.error(error);
    }
  };
  const commentOnTweet = async (tweetId, commentContent) => {
    console.log({ tweetId, commentContent });
    try {
      if (!contract || !web3 || !commentContent) return;
      await contract.methods
        .commentOnTweet(tweetId, commentContent)
        .send({ from: accounts[0] });
      fetchTweets();
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <div className="container">
      <h1>Basic Twitter</h1>
      <div>
        <h2>Create Tweet</h2>
        <textarea
          value={newTweetContent}
          onChange={handleChange}
          placeholder="Type your tweet here..."
        />
        <button onClick={createTweet}>Tweet</button>
      </div>
      <div>
        <h2>All Tweets</h2>
        <ul>
          {tweets?.map((tweet, index) => (
            <li key={index}>
              <p>Content: {tweet.content}</p>
              <p>Author: {tweet.author}</p>
              <p>Likes: {parseInt(tweet.countLikes)}</p>
              <p>Comments: {parseInt(tweet.countComments)}</p>
              <button onClick={() => toggleCommentVisibility(tweet.id, index)}>
                {commentVisibility[index] ? "Hide Comments" : "Read Comments"}
              </button>
              <button onClick={() => likeTweet(tweet.id)}>Like</button>
              <div>
                {commentVisibility[index] && (
                  <div>
                    <h3>Comments</h3>
                    <ul>
                      {tweet.comments?.map((comment, idx) => (
                        <li key={idx}>
                          <p>Content: {comment.content}</p>
                          <p>Commenter: {comment.commenter}</p>
                          <p>Timestamp: {comment.timestamp}</p>
                        </li>
                      ))}
                    </ul>
                    <textarea
                      value={newCommentContent}
                      onChange={handleChangeNewCommentContent}
                      placeholder="Type your comment here..."
                    />
                    <button
                      onClick={() =>
                        commentOnTweet(tweet.id, newCommentContent)
                      }
                    >
                      Comment
                    </button>
                  </div>
                )}
              </div>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}

export default App;
