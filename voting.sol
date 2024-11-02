// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
contract Vote{

//first entity 
struct Voter{
    string name;
    uint age;
    Gender gender;
    uint voterId;
    uint candiateId;
    address voteraddress;
}

//second entity
struct Candidate{
   string name;
    uint age;
    string party;
    Gender gender;
    uint candiateId;
    address candidate_address;
    uint votes;
}


address public electionCommission;
address public winner;
uint nextvoterId=1;
uint nextCandidateId=1;

uint startTime;
uint endTime;
bool stopvoting;

mapping (uint => Voter) voterDetails;
mapping (uint => Candidate ) candidateDetails;

enum VotingStatus{Notstarted, Inprogress, Ended}
enum Gender{NotSepecified,Male,Female,Other}


constructor(){
    electionCommission=msg.sender;
}

modifier isVoting{
    require(block.timestamp<=endTime && stopvoting==false,"Voting time is over");
    _;
}

modifier onlyCommissoner(){
    require(msg.sender==electionCommission,"Not authuorized");
    _;
}

modifier Validage(uint _age){
    require(_age>=18,"not eligible for voting");
    _;
}

// FOR CANDIDATE REGISTRATION

function registeredCandidate(
    string calldata _name,
    string calldata _party,
    uint _age,
    Gender _gender
)external Validage(_age){
require(isCandidateNotregistered(msg.sender),"You are already registered");
require(nextCandidateId<3,"Candidate registeation Full");
require(msg.sender!=electionCommission,"election commision are not allowed to register");
 
 candidateDetails[nextCandidateId]=Candidate({
    name:_name,
    party:_party,
    gender:_gender,
    age:_age,
    candiateId:nextCandidateId,
    candidate_address:msg.sender,
    votes:0
 });
nextCandidateId++;
}

function isCandidateNotregistered(address _person) private view returns (bool){
    for(uint i=1;i<nextCandidateId;i++){
        if (candidateDetails[i].candidate_address==_person){
            return false;
        }
    }
    return true;
}

function getCandiateList() public view returns (Candidate[] memory){
    Candidate[] memory candidatelist= new Candidate[](nextCandidateId-1);
    for(uint i=0;i<candidatelist.length;i++){
        candidatelist[i]=candidateDetails[i+1];
    }
    return candidatelist;
}

//FOR VOTER REGISTRATION PROCESS
function VoterisNotregister(address _voter) private view returns(bool){
    {
        for(uint i=0;i<nextvoterId;i++){
            if (voterDetails[i].voteraddress==_voter){
                return false;
            }
        }
        return true;
    }
}

function registerVoter(
    string calldata _name,
    uint _age,
    Gender _gender
)external Validage(_age){
    require(VoterisNotregister(msg.sender),"you are already registered");
    voterDetails[nextvoterId]=Voter({
         name:_name,
            age:_age,
            voterId:nextvoterId,
            gender:_gender,
            candiateId:0,
            voteraddress:msg.sender
    });
    nextvoterId++;
}

function getVoterlist() public view returns (Voter [] memory)
{
    uint lengthArr= nextvoterId-1;
    Voter[] memory voterList=new Voter[](lengthArr);
    for(uint i=0;i<voterList.length;i++){
        voterList[i]=voterDetails[i+1];
    }
return voterList;
}

function castVote(uint _voterId ,uint _candidateId)   external isVoting(){

    require(block.timestamp>=startTime,"voting has not started yet");
    require(voterDetails[_voterId].candiateId==0,"you have already voted");
    require(voterDetails[_voterId].voteraddress==msg.sender,"you are not authorized");
    require(_candidateId>=1 && _candidateId<3,"candidate id is not correct");

    voterDetails[_voterId].candiateId=_candidateId;
    candidateDetails[_candidateId].votes++;
}


function getVotingStaus() public view returns (VotingStatus){
    if(startTime==0){
     return VotingStatus.Notstarted;
    }
    else if(endTime>block.timestamp && stopvoting==false){
        return VotingStatus.Inprogress;
    }
    else{
        return VotingStatus.Ended;
    }
}

function annonceVotinngResult () external onlyCommissoner() {
uint max=0;
for(uint i=1;i<nextCandidateId;i++){
    if(candidateDetails[i].votes>max){
        max=candidateDetails[i].votes;
        winner=candidateDetails[i].candidate_address;
    }
}


}


function emergencyStopVoting() public onlyCommissoner(){
    stopvoting=true;
}

}






