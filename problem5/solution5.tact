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
        let ctx: Context = context();
        if (ctx.value < ton("0.005")) {
            throw(2024);
        }
        self.proposalId = data.proposalId;
        self.votingEndingAt = data.votingEndingAt;
        self.voters = emptyMap();
        self.yesVotesCount = 0;
        self.noVotesCount = 0;
    }

    // deploy
    receive() {
        let ctx: Context = context();
        if (ctx.value < ton("0.005")) {
            throw(2024);
        }
    }

    receive(msg: Vote) {
        let ctx: Context = context();
        let sender: Address = ctx.sender;

        throwUnless(1000, now() <= self.votingEndingAt);
        throwUnless(1002, !self.voters.exists(sender));
        if (ctx.value < ton("0.005")) {
            throw(2024);
        }

        if (msg.value) {
            self.yesVotesCount += 1;
        } else {
            self.noVotesCount += 1;
        }

        if ((self.yesVotesCount + self.noVotesCount) % 13 == 0) {
            self.voters = emptyMap();
        }
        self.voters.set(sender, true);
        cashback(sender);
    }


    get fun proposalState(): ProposalState {
        return ProposalState {
            yesCount: self.yesVotesCount,
            noCount: self.noVotesCount
        };

    }
}

