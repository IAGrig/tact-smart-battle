struct ProposalInit {
    master: Address;
    proposalId: Int as uint32;
}

message DeployNewProposal {
    votingEndingAt: Int as uint32;
}

contract ProposalMaster {
    nextProposalId: Int as uint32 = 0;

    // deploy
    receive() { }

    receive(msg: DeployNewProposal) {
        throwUnless(1020, now() <= msg.votingEndingAt);
		deploy(DeployParameters{
			init: initOf Proposal(ProposalInit{ master: myAddress(), proposalId: self.nextProposalId }),
			body: msg.toCell(),
			mode: SendRemainingValue + SendIgnoreErrors,
			value: ton("0"),
		});
		self.nextProposalId += 1;
    }

    get fun nextProposalId(): Int {
        return self.nextProposalId;
    }
}

// ==============================================================================

message Vote {
    value: Bool;
}

struct ProposalState {
    yesCount: Int as uint32;
    noCount: Int as uint32;
    master: Address;
    proposalId: Int as uint32;
    votingEndingAt: Int as uint32;
}

contract Proposal {
    master: Address;
    proposalId: Int as uint32;
    yesCount: Int as uint32;
    noCount: Int as uint32;
    votingEndingAt: Int? as uint32;
    voters: map<Address, Bool>;

    init(data: ProposalInit) {
		throwUnless(2025, data.master == sender());
        self.master = data.master;
        self.proposalId = data.proposalId;
        self.yesCount = 0;
        self.noCount = 0;
        self.voters = emptyMap();
    }

    receive(msg: DeployNewProposal) {
		throwUnless(2025, self.master == sender());
        self.votingEndingAt = msg.votingEndingAt;
    }

    receive(msg: Vote) {
        let sender: Address = sender();
        throwUnless(1000, now() <= self.votingEndingAt!!);
        throwUnless(1001, self.yesCount + self.noCount < 100);
        throwUnless(1002, !self.voters.exists(sender));

        self.voters.set(sender, true);
        if (msg.value) {
            self.yesCount += 1;
        } else {
            self.noCount += 1;
        }
    }

    get fun proposalState(): ProposalState {
        return ProposalState {
            yesCount: self.yesCount,
            noCount: self.noCount,
            master: self.master,
            proposalId: self.proposalId,
            votingEndingAt: self.votingEndingAt!!
        };
    }

}

