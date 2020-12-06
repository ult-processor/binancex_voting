// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.21 <=0.7.0

/*
Election contract that allows the owner to issue voting rights
to anybody and also end the election and announce results
*/
contract Election {
    
    //a struct data type to model the candidates in the Election
    struct Candidate {
        
        // a string vairable that represents the candidates name
        string name;
        
        // an unsigned integer that  that keeps track of the amount of votes of the candidates
        uint voteCount;
    }
    
    // a struct data type used to model the Voter in the election.
    struct Voter {
        
        // a boolean  datatype for keeping tract of authorized  Voters.
        bool authorized;
        
        // a boolean  datatype to track wheter the voter has voted or not.
        bool voted;
        
        //for tracking whom they voted for, we have several candidates  real number intergers for representing the candidates starting from candidate 0.
        uint vote;
    }
    
    //for keeping track of the owner address, i.e the wallet adress of the person that deployed the contract into the binance smart chain.
    address payable public owner;
    
    //the name of the election or what the election is about
    string public electionName;

    // a mapping datastructure which is keeping track of the voters address
    mapping(address => Voter) public voters;
    
    //keeping track of candidates in an array.
    Candidate[] public candidates;

    //emitting the result after the election is over
    event ElectionResult(string candidateName, uint voteCount);

    //the modifier checking whether the sender is the owner of the smart contract.
    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }


    //setting a contructor function that get executed imideately the contract is sent to the binance smartchain.
    constructor(string memory _name) public {
        
        //setting the address that deployed the contract to the owner of the contract
        owner = msg.sender;
        electionName = _name;
    }
     
     //adding candidates to the list of candidates 
    function addCandidate(string memory name) ownerOnly public {
        
        //pushing the candidate into the array
        candidates.push(Candidate(name, 0));
    }

    //authorizing voters wallet adress to be able to participate in the  to 
    function authorize(address person) ownerOnly public {
        voters[person].authorized = true;
    }
    
    
    //used to cast vote by authorized candidates and for the respective candidate or option
    function vote(uint voteIndex) public {
        //make sure voter is authorized and has not already voted
        require(!voters[msg.sender].voted);
        require(voters[msg.sender].authorized);

        //record vote
        voters[msg.sender].vote = voteIndex;
        voters[msg.sender].voted = true;

        //increase candidate vote count by 1
        candidates[voteIndex].voteCount += 1;
    }

    function end() ownerOnly public {
        //announce each candidates results
        for(uint i=0; i < candidates.length; i++) {
            emit ElectionResult(candidates[i].name, candidates[i].voteCount);
        }

        //destroy the contract
        selfdestruct(owner);
    }
}
