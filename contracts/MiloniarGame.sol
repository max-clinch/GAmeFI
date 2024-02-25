// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./MiliToken.sol";
//import "./interface.sol";
contract MillionaireGame is Ownable(msg.sender) {
    using Math for uint256;

    uint256 public currentQuestionIndex;
    uint256 public totalPrizePool;
    uint256 public constant MAX_QUESTIONS = 100; // Changed to accommodate more questions
    uint256 public constant TIME_LIMIT = 600; // Time limit for answering each question (in seconds)
    uint256 public constant COOLDOWN_PERIOD = 4 days; // Cooldown period for playing again
    uint256 public constant LIFELINE_FEE = 1; // Fee for using lifeline in token units

    struct Question {
        string question;
        string[4] choices;
        string correctChoice; // Changed to string type for answers
        uint256 difficultyLevel;
    }

    Question[MAX_QUESTIONS] public questions;

    mapping(address => uint256) public participantBalances;
    mapping(address => bool) public isParticipant;
    mapping(address => uint256) public lastPlayedTimestamp;
    address[] public leaderboard;

    ERC20 public token;

    event QuestionAsked(string question, string[4] choices);
    event PrizeWon(address winner, uint256 amount);
    event GameEnded();
    event LifelineUsed(address user, string lifelineType);
    event TokensEarned(address user, uint256 amount);

    constructor(address _tokenAddress) {
        token = ERC20(_tokenAddress);
        currentQuestionIndex = 0;
        totalPrizePool = 0;

         // Initialize questions (simplified for example)
        questions[0] = Question(
            "What is the capital of France?",
            ["Paris", "London", "Berlin", "Madrid"],
            "Paris",
            1
        );
        questions[1] = Question(
            "Which planet is known as the Red Planet?",
            ["Mars", "Venus", "Jupiter", "Saturn"],
            "Mars",
            1
        );
        questions[2] = Question(
            "Who wrote 'To Kill a Mockingbird'?",
            ["Harper Lee", "Stephen King", "J.K. Rowling", "Charles Dickens"],
            "Harper Lee",
            1
        );
        questions[3] = Question(
            "What is the largest mammal in the world?",
            ["Elephant", "Blue Whale", "Giraffe", "Hippopotamus"],
            "Blue Whale",
            1
        );
        questions[4] = Question(
            "Which country is home to the kangaroo?",
            ["Australia", "Brazil", "Canada", "India"],
            "Australia",
            1
        );
        questions[5] = Question(
            "Who is the CEO of Tesla Inc.?",
            ["Elon Musk", "Jeff Bezos", "Bill Gates", "Mark Zuckerberg"],
            "Elon Musk",
            1
        );
        questions[6] = Question(
            "Which element has the chemical symbol 'Fe'?",
            ["Iron", "Gold", "Silver", "Copper"],
            "Iron",
            1
        );
        questions[7] = Question(
            "What is the capital of Japan?",
            ["Tokyo", "Seoul", "Beijing", "Bangkok"],
            "Tokyo",
            1
        );
        questions[8] = Question(
            "Who painted the Mona Lisa?",
            [
                "Leonardo da Vinci",
                "Vincent van Gogh",
                "Pablo Picasso",
                "Michelangelo"
            ],
            "Leonardo da Vinci",
            1
        );
        questions[9] = Question(
            "What is the boiling point of water in Celsius?",
            ["100\u00B0C", "0\u00B0C", "50\u00B0C", "200\u00B0C"],
            "100\u00B0C",
            1
        );
        questions[10] = Question(
            "What is the chemical symbol for gold?",
            ["Au", "Ag", "Hg", "Pt"],
            "Au",
            1
        );
        questions[11] = Question(
            "Which continent is the largest by land area?",
            ["Asia", "Africa", "North America", "South America"],
            "Asia",
            1
        );
        questions[12] = Question(
            "Who discovered penicillin?",
            [
                "Alexander Fleming",
                "Marie Curie",
                "Louis Pasteur",
                "Albert Einstein"
            ],
            "Alexander Fleming",
            1
        );
        questions[13] = Question(
            "What is the main ingredient in guacamole?",
            ["Avocado", "Tomato", "Onion", "Lemon"],
            "Avocado",
            1
        );
        questions[14] = Question(
            "Which planet is closest to the sun?",
            ["Mercury", "Venus", "Earth", "Mars"],
            "Mercury",
            1
        );
        questions[15] = Question(
            "What is the currency of Japan?",
            ["Yen", "Won", "Dollar", "Euro"],
            "Yen",
            1
        );
        questions[16] = Question(
            "Who is known as the 'Father of Computer'?",
            ["Charles Babbage", "Alan Turing", "Steve Jobs", "Bill Gates"],
            "Charles Babbage",
            1
        );
        questions[17] = Question(
            "Which gas is most abundant in the Earth's atmosphere?",
            ["Nitrogen", "Oxygen", "Carbon Dioxide", "Argon"],
            "Nitrogen",
            1
        );
        questions[18] = Question(
            "Which planet is known as the 'Morning Star'?",
            ["Venus", "Mars", "Jupiter", "Saturn"],
            "Venus",
            1
        );
        questions[19] = Question(
            "What is the chemical symbol for sodium?",
            ["Na", "So", "Sn", "Si"],
            "Na",
            1
        );
        questions[20] = Question(
            "Who wrote 'Romeo and Juliet'?",
            [
                "William Shakespeare",
                "Jane Austen",
                "Mark Twain",
                "Charles Dickens"
            ],
            "William Shakespeare",
            1
        );
        questions[21] = Question(
            "What is the capital of Brazil?",
            ["Brasilia", "Rio de Janeiro", "Sao Paulo", "Salvador"],
            "Brasilia",
            1
        );
        questions[22] = Question(
            "What is the largest organ in the human body?",
            ["Skin", "Liver", "Heart", "Brain"],
            "Skin",
            1
        );
        questions[23] = Question(
            "Who is the author of 'The Great Gatsby'?",
            [
                "F. Scott Fitzgerald",
                "Ernest Hemingway",
                "William Faulkner",
                "John Steinbeck"
            ],
            "F. Scott Fitzgerald",
            1
        );
        questions[24] = Question(
            "What is the chemical symbol for oxygen?",
            ["O", "Ox", "O2", "O3"],
            "O",
            1
        );
        questions[25] = Question(
            "Which city is known as the 'City of Love'?",
            ["Paris", "Rome", "Venice", "Barcelona"],
            "Paris",
            1
        );
        questions[26] = Question(
            "What is the largest ocean on Earth?",
            ["Pacific Ocean", "Atlantic Ocean", "Indian Ocean", "Arctic Ocean"],
            "Pacific Ocean",
            1
        );
        questions[27] = Question(
            "Who painted the ceiling of the Sistine Chapel?",
            ["Michelangelo", "Leonardo da Vinci", "Raphael", "Donatello"],
            "Michelangelo",
            1
        );
        questions[28] = Question(
            "What is the chemical symbol for carbon?",
            ["C", "Ca", "Co", "Cr"],
            "C",
            1
        );
        questions[29] = Question(
            "Which country is known as the 'Land of the Rising Sun'?",
            ["Japan", "China", "Korea", "Vietnam"],
            "Japan",
            1
        );
        questions[30] = Question(
            "Who wrote 'Harry Potter' series?",
            [
                "J.K. Rowling",
                "Stephen King",
                "George R.R. Martin",
                "J.R.R. Tolkien"
            ],
            "J.K. Rowling",
            1
        );
        questions[31] = Question(
            "What is the hardest natural substance on Earth?",
            ["Diamond", "Steel", "Titanium", "Graphite"],
            "Diamond",
            1
        );
        questions[32] = Question(
            "What is the tallest mountain in the world?",
            ["Mount Everest", "K2", "Kangchenjunga", "Lhotse"],
            "Mount Everest",
            1
        );
        questions[33] = Question(
            "Who is known as the 'Queen of Soul'?",
            ["Aretha Franklin", "Whitney Houston", "Beyonce", "Mariah Carey"],
            "Aretha Franklin",
            1
        );
        questions[34] = Question(
            "Which planet is known as the 'Evening Star'?",
            ["Venus", "Mars", "Jupiter", "Saturn"],
            "Venus",
            1
        );
        questions[35] = Question(
            "What is the chemical symbol for silver?",
            ["Ag", "Si", "Sv", "Sl"],
            "Ag",
            1
        );
        questions[36] = Question(
            "Who was the first man to walk on the moon?",
            ["Neil Armstrong", "Buzz Aldrin", "Yuri Gagarin", "Alan Shepard"],
            "Neil Armstrong",
            1
        );
        questions[37] = Question(
            "What is the capital of Italy?",
            ["Rome", "Milan", "Florence", "Naples"],
            "Rome",
            1
        );
        questions[38] = Question(
            "What is the smallest country in the world?",
            ["Vatican City", "Monaco", "San Marino", "Liechtenstein"],
            "Vatican City",
            1
        );
        questions[39] = Question(
            "Who is the author of 'War and Peace'?",
            [
                "Leo Tolstoy",
                "Fyodor Dostoevsky",
                "Anton Chekhov",
                "Ivan Turgenev"
            ],
            "Leo Tolstoy",
            1
        );
        questions[40] = Question(
            "What is the chemical symbol for helium?",
            ["He", "Hl", "Hm", "Hn"],
            "He",
            1
        );
        questions[41] = Question(
            "Which country is known as the 'Land of the Midnight Sun'?",
            ["Norway", "Sweden", "Finland", "Iceland"],
            "Norway",
            1
        );
        questions[42] = Question(
            "Who is the director of the movie 'Schindler's List'?",
            [
                "Steven Spielberg",
                "Martin Scorsese",
                "Quentin Tarantino",
                "Alfred Hitchcock"
            ],
            "Steven Spielberg",
            1
        );
        questions[43] = Question(
            "What is the chemical symbol for potassium?",
            ["K", "Ka", "Kp", "Ko"],
            "K",
            1
        );
        questions[44] = Question(
            "Who invented the telephone?",
            [
                "Alexander Graham Bell",
                "Thomas Edison",
                "Nikola Tesla",
                "Guglielmo Marconi"
            ],
            "Alexander Graham Bell",
            1
        );
        questions[45] = Question(
            "What is the largest desert in the world?",
            [
                "Sahara Desert",
                "Arctic Desert",
                "Gobi Desert",
                "Kalahari Desert"
            ],
            "Sahara Desert",
            1
        );
        questions[46] = Question(
            "Who painted 'Starry Night'?",
            [
                "Vincent van Gogh",
                "Pablo Picasso",
                "Leonardo da Vinci",
                "Claude Monet"
            ],
            "Vincent van Gogh",
            1
        );
        questions[47] = Question(
            "What is the chemical symbol for lead?",
            ["Pb", "Pl", "Pd", "Pe"],
            "Pb",
            1
        );
        questions[48] = Question(
            "Who wrote 'The Catcher in the Rye'?",
            [
                "J.D. Salinger",
                "F. Scott Fitzgerald",
                "Ernest Hemingway",
                "Mark Twain"
            ],
            "J.D. Salinger",
            1
        );
        questions[49] = Question(
            "What is the chemical symbol for iron?",
            ["Fe", "Ir", "In", "Fr"],
            "Fe",
            1
        );
        questions[50] = Question(
            "Which river is the longest in the world?",
            ["Nile", "Amazon", "Yangtze", "Mississippi"],
            "Nile",
            1
        );
        questions[51] = Question(
            "Who founded Microsoft?",
            ["Bill Gates", "Steve Jobs", "Jeff Bezos", "Larry Page"],
            "Bill Gates",
            1
        );
        questions[52] = Question(
            "What is the capital of Spain?",
            ["Madrid", "Barcelona", "Valencia", "Seville"],
            "Madrid",
            1
        );
        questions[53] = Question(
            "What is the chemical symbol for calcium?",
            ["Ca", "Ce", "Cm", "Cn"],
            "Ca",
            1
        );
        questions[54] = Question(
            "Who wrote '1984'?",
            [
                "George Orwell",
                "Aldous Huxley",
                "Ray Bradbury",
                "Margaret Atwood"
            ],
            "George Orwell",
            1
        );
        questions[55] = Question(
            "Which animal is known as the 'King of the Jungle'?",
            ["Lion", "Tiger", "Leopard", "Cheetah"],
            "Lion",
            1
        );
        questions[56] = Question(
            "What is the chemical symbol for copper?",
            ["Cu", "Co", "Cp", "Ct"],
            "Cu",
            1
        );
        questions[57] = Question(
            "Who painted 'The Last Supper'?",
            ["Leonardo da Vinci", "Michelangelo", "Raphael", "Donatello"],
            "Leonardo da Vinci",
            1
        );
        questions[58] = Question(
            "Which planet is known as the 'Red Planet'?",
            ["Mars", "Venus", "Jupiter", "Mercury"],
            "Mars",
            1
        );
        questions[59] = Question(
            "What is the chemical symbol for nitrogen?",
            ["N", "Ni", "Ne", "Na"],
            "N",
            1
        );
        questions[60] = Question(
            "Who discovered gravity?",
            [
                "Isaac Newton",
                "Galileo Galilei",
                "Albert Einstein",
                "Stephen Hawking"
            ],
            "Isaac Newton",
            1
        );
        questions[61] = Question(
            "What is the largest bird in the world?",
            ["Ostrich", "Emu", "Albatross", "Condor"],
            "Ostrich",
            1
        );
        questions[62] = Question(
            "Who wrote 'Pride and Prejudice'?",
            [
                "Jane Austen",
                "Charlotte Bronte",
                "Emily Dickinson",
                "Virginia Woolf"
            ],
            "Jane Austen",
            1
        );
        questions[63] = Question(
            "What is the chemical symbol for gold?",
            ["Au", "Ag", "Pt", "Pb"],
            "Au",
            1
        );

        
    }


    function register() external {
        require(!isParticipant[msg.sender], "Already registered");
        isParticipant[msg.sender] = true;
    }

    function getCurrentQuestion()
        external
        view
        returns (string memory question, string[4] memory choices)
    {
        require(currentQuestionIndex < MAX_QUESTIONS, "No question available");
        Question storage currentQuestion = questions[currentQuestionIndex];
        return (currentQuestion.question, currentQuestion.choices);
    }

    function answerQuestion(string memory _choice) external {
        require(isParticipant[msg.sender], "Not registered");
        require(bytes(_choice).length > 0, "Invalid choice");

        string memory correctChoice = questions[currentQuestionIndex]
            .correctChoice;

        // Compare the user's choice with the correct choice
        require(compareStrings(_choice, correctChoice), "Incorrect answer");

        // Update last played timestamp
        lastPlayedTimestamp[msg.sender] = block.timestamp;

        // Reward the user for correct answer
        token.transfer(msg.sender, 3); // Rewarding 3 tokens for each correct answer

        // Move to the next question or end the game
        if (currentQuestionIndex < MAX_QUESTIONS - 1) {
            currentQuestionIndex++;
        } else {
            endGame();
        }
    }

    function useLifeline(uint256 lifeline) external {
        require(isParticipant[msg.sender], "Not registered");
        require(lifeline >= 0 && lifeline < 3, "Invalid lifeline");
        require(
            token.balanceOf(msg.sender) >= LIFELINE_FEE,
            "Insufficient tokens"
        );

        // Deduct lifeline cost
        token.transferFrom(msg.sender, address(this), LIFELINE_FEE);

        // Implement lifeline functionality based on lifeline type
        if (lifeline == 0) {
            // Implement 50/50 lifeline
            // Randomly select two incorrect choices to eliminate
            uint256[2] memory choicesToRemove;
            uint256 numRemoved = 0;
            for (uint256 i = 0; i < 4; i++) {
                if (
                    !compareStrings(
                        questions[currentQuestionIndex].choices[i],
                        questions[currentQuestionIndex].correctChoice
                    ) && numRemoved < 2
                ) {
                    choicesToRemove[numRemoved] = i;
                    numRemoved++;
                }
            }
            emit LifelineUsed(msg.sender, "50/50");
        } else if (lifeline == 1) {
            // Implement "Ask the Audience" lifeline
            // For simplicity, we assume 70% correct audience answer
            uint256 correctAnswerPercentage = 70;
            uint256 correctChoiceIndex = findChoiceIndex(
                questions[currentQuestionIndex].correctChoice
            );
            uint256 audienceChoice = correctAnswerPercentage > 50
                ? correctChoiceIndex
                : (correctChoiceIndex + 1) % 4; // Assuming 70% audience picks the correct answer
            emit LifelineUsed(msg.sender, "Ask the Audience");
            // Use audienceChoice here
            audienceChoice;
        } else if (lifeline == 2) {
            // Implement "Phone a Friend" lifeline
            // For simplicity, we assume the friend knows the answer with 90% probability
            uint256 correctAnswerProbability = 90;
            uint256 correctChoiceIndex = findChoiceIndex(
                questions[currentQuestionIndex].correctChoice
            );
            uint256 friendChoice = correctAnswerProbability > 50
                ? correctChoiceIndex
                : (correctChoiceIndex + 1) % 4; // Assuming 90% probability of friend knowing the answer
            emit LifelineUsed(msg.sender, "Phone a Friend");
            // Use friendChoice here
            friendChoice;
        }
    }

    function endGame() public {
        // Calculate total prize pool
        totalPrizePool = token.balanceOf(address(this));

        // Determine winners and distribute prizes
        for (uint256 i = 0; i < MAX_QUESTIONS; i++) {
            address winner = getWinner(i);
            if (winner != address(0)) {
                uint256 prize = totalPrizePool / (MAX_QUESTIONS);
                token.transfer(winner, prize);
                emit PrizeWon(winner, prize);
                leaderboard.push(winner);
            }
        }

        // Reset game state
        currentQuestionIndex = 0;
        totalPrizePool = 0;

        // Emit event
        emit GameEnded();
    }

    function getWinner(
        uint256 /* questionIndex */
    ) private view returns (address) {
        uint256 lastQuestionIndex = MAX_QUESTIONS - 1;

        if (lastPlayedTimestamp[msg.sender] >= lastQuestionIndex) {
            return msg.sender;
        } else {
            return address(0);
        }
    }

    function findChoiceIndex(string memory _choice)
        private
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < 4; i++) {
            if (
                compareStrings(
                    _choice,
                    questions[currentQuestionIndex].choices[i]
                )
            ) {
                return i;
            }
        }
        revert("Choice not found");
    }
    

    function compareStrings(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return
            (bytes(a).length == bytes(b).length) &&
            (keccak256(bytes(a)) == keccak256(bytes(b)));
    }
     function claimTokens() external {
        require(isParticipant[msg.sender], "Not registered");
        require(currentQuestionIndex == MAX_QUESTIONS, "Game not ended");

        // Calculate the number of tokens to be claimed based on participation
        uint256 participationTokens = calculateParticipationTokens();

        // Transfer the earned tokens to the participant
        token.transfer(msg.sender, participationTokens);

        // Emit event
        emit TokensEarned(msg.sender, participationTokens);
    }

// Helper function to calculate participation tokens
    function calculateParticipationTokens() internal view returns (uint256) {
        uint256 totalParticipants = leaderboard.length;
        uint256 participantTokens = totalPrizePool / totalParticipants;

        // Use a conditional statement 
        return participantBalances[msg.sender] < participantTokens
            ? participantBalances[msg.sender]
            : participantTokens;
    }
}
