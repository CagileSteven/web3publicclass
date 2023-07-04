pragma solidity ^0.8.0;

contract Vote {
    address public admin;
    bool public votingOpen;
    uint public currentTopicId;
    uint public totalVotes;
    mapping(uint => Topic) public topics;
    mapping(uint => mapping(address => bool)) public hasVoted;
    mapping(address => uint) public userVotes;
    mapping(address => bool) public isVoter;
    
    struct Topic {
        string name;
        string description;
        uint yesVotes;
        uint noVotes;
        bool open;
    }
    
    event TopicCreated(uint id, string name, string description);
    event VotingOpened(uint id);
    event VotingClosed(uint id, uint yesVotes, uint noVotes);
    event Voted(uint topicId, address voter);
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "You are not authorized.");
        _;
    }
    
    modifier votingIsActive() {
        require(votingOpen, "Voting closed.");
        _;
    }
    
    constructor() {
        admin = msg.sender;
    }
    
    function createTopic(string memory name, string memory description) public onlyAdmin {
        require(!votingOpen, "Voting is currently open.");
        currentTopicId++;
        topics[currentTopicId] = Topic(name, description, 0, 0, false);
        emit TopicCreated(currentTopicId, name, description);
    }
    
    function openVoting(uint topicId) public onlyAdmin {
        Topic storage topic = topics[topicId];
        require(!votingOpen, "Voting is open already.");
        require(topic.open == false, "Voting for this topic is open already.");
        topic.open = true;
        votingOpen = true;
        emit VotingOpened(topicId);
    }
    
    function closeVoting(uint topicId) public onlyAdmin {
        Topic storage topic = topics[topicId];
        require(votingOpen, "Voting is not open.");
        require(topic.open == true, "Voting for this topic is not open.");
        topic.open = false;
        votingOpen = false;
        emit VotingClosed(topicId, topic.yesVotes, topic.noVotes);
    }
    
    function vote(uint topicId, bool choice) public votingIsActive {
        Topic storage topic = topics[topicId];
        require(isVoter[msg.sender] == false, "You have already voted.");
        require(hasVoted[topicId][msg.sender] == false, "You have already voted for this topic.");
        require(choice == true || choice == false, "You must choose either yes or no.");
        if (choice) {
            topic.yesVotes++;
        } else {
            topic.noVotes++;
        }
        totalVotes++;
        hasVoted[topicId][msg.sender] = true;
        userVotes[msg.sender] = topicId;
        isVoter[msg.sender] = true;
        emit Voted(topicId, msg.sender);
    }
    
    function rewardVoters(uint topicId, address[] memory correctVoters, uint rewardAmount) public onlyAdmin {
        Topic storage topic = topics[topicId];
        require(!votingOpen, "Voting is still open.");
        require(topic.open == false, "Voting for this topic is still open.");
        require(correctVoters.length > 0, "There must be at least one correct voter.");
        uint rewardPerVoter = rewardAmount / correctVoters.length;
        for (uint i = 0; i < correctVoters.length; i++) {
            address voter = correctVoters[i];
            if (hasVoted[topicId][voter] == true) {
                // Voter voted for the winning choice
                if ((userVotes[voter] == topicId && topic.yesVotes > topic.noVotes) ||
                    (userVotes[voter] != topicId && topic.yesVotes < topic.noVotes)) {
                    // Voter voted for the correct choice
                    // Transfer reward to voter
                    // Assuming we're using an ERC20 token
                    // require(token.transfer(voter, rewardPerVoter), "Transfer failed.");
                }
            }
        }
    }
}