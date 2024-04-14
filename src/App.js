import Web3 from "web3";
import contract from "./contracts/artifacts/BasicTwitter_metadata.json";
import { useEffect, useState } from "react";
import "./App.css"; // Import CSS file
const contractAddress = "0x5bee07794E62f2216406e2F1Bc2E92A4d40aE270"; // Replace with your contract address
const contractABI = contract.output.abi;

function App() {
  const [web3, setWeb3] = useState(null);
  const [contract, setContract] = useState(null);
  const [accounts, setAccounts] = useState([]);
  const [tweets, setTweets] = useState([]);
  const [newTweetContent, setNewTweetContent] = useState("");

  useEffect(() => {
    async function init() {
      // Check if MetaMask is installed
      if (window.ethereum) {
        try {
          // Request account access if needed
          await window.ethereum.request({ method: "eth_requestAccounts" });
          const web3Instance = new Web3(window.ethereum);
          setWeb3(web3Instance);

          // Use web3 to get the user's accounts
          const accounts = await web3Instance.eth.getAccounts();
          setAccounts(accounts);

          // Instantiate the contract
          const contractInstance = new web3Instance.eth.Contract(
            contractABI,
            contractAddress
          );
          setContract(contractInstance);
        } catch (error) {
          console.error(error);
        }
      } else {
        console.error("MetaMask extension not detected!");
      }
    }
    init();
  }, []);

  const createTweet = async () => {
    try {
      if (!contract || !web3) return;
      if (!newTweetContent) return;

      // Send transaction to create a new tweet
      await contract.methods
        .createTweet(newTweetContent)
        .send({ from: accounts[0] });

      // Update the tweet list
      fetchTweets();
    } catch (error) {
      console.error(error);
    }
  };

  const fetchTweets = async () => {
    try {
      if (!contract) return;

      // Call the contract function to fetch tweets
      const fetchedTweets = await contract.methods
        .getMyTweets()
        .call({ from: accounts[0] });
      setTweets(fetchedTweets);
    } catch (error) {
      console.error(error);
    }
  };

  const handleChange = (event) => {
    setNewTweetContent(event.target.value);
  };

  return (
    <div>
      <h1>Basic Twitter</h1>
      <div>
        <h2>Create Tweet</h2>
        <textarea value={newTweetContent} onChange={handleChange} />
        <button onClick={createTweet}>Tweet</button>
      </div>
      <div>
        <h2>My Tweets</h2>
        <ul>
          {tweets.map((tweet, index) => (
            <li key={index}>
              <p>{tweet.content}</p>
              <p>Author: {tweet.author}</p>
              <p>Timestamp: {tweet.timestamp}</p>
              <p>Views: {tweet.amountViews}</p>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}

export default App;
