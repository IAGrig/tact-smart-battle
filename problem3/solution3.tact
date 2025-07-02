//
// Public solution template
//

message Vote {
    value: Bool;
}

struct ProposalState {
    yesCount: Int as uint32;
    noCount: Int as uint32;
}

struct Init {
    proposalId: Int as uint32;
    votingEndingAt: Int as uint32;
}

contract Proposal {
    proposalId: Int as uint32;
    votingEndingAt: Int as uint32;
    voters: map<Address, Bool>;
    yesVotesCount: Int as uint32;
    noVotesCount: Int as uint32;


    init(data: Init) {
        self.proposalId = data.proposalId;
        self.votingEndingAt = data.votingEndingAt;
        self.voters = emptyMap();
        self.yesVotesCount = 0;
        self.noVotesCount = 0;
    }

    // deploy
    receive() { }

    receive(msg: Vote) {
        let sender: Address = sender();
        throwUnless(1000, now() <= self.votingEndingAt);
        throwUnless(1002, !self.voters.exists(sender));


        self.voters.set(sender, true);
        if (msg.value) {
            self.yesVotesCount += 1;
        } else {
            self.noVotesCount += 1;
        }
        if ( (self.yesVotesCount + self.noVotesCount) % 5 == 0) {
            self.voters = emptyMap();
        }
    }

    get fun proposalState(): ProposalState {
        return ProposalState {
            yesCount: self.yesVotesCount,
            noCount: self.noVotesCount
        };

    }
}

