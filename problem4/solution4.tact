struct ProposalInit {
    master: Address;
    proposalId: Int as uint32;
}

message DeployNewProposal {
    votingEndingAt: Int as uint32;
}

message DeployNewProposalAddr {
    votingEndingAt: Int as uint32;
    user: Address;
}

contract ProposalMaster {
    nextProposalId: Int as uint32 = 0;

    // top up
    //must return excess funds back to the wallet of the user who initiated the transaction

    //increases the contract balance to 0.01 TON each time it is invoked.
    // The contract should accept all the funds if the incoming message carries a smaller TON amount.
    receive() {
        let balance: Int = myBalance();
        // dump(balance);
        if (balance > 100000000) {
            message(MessageParameters {to: sender(), value: balance - 100000000} );
            // dump(balance - 100000000);
        }
        // dump(myBalance());
    }

    //must return excess funds back to the wallet of the user who initiated the transaction
    receive(msg: DeployNewProposal) {
        // TODO: implement
        throwUnless(1020, now() <= msg.votingEndingAt);
		deploy(DeployParameters{
			init: initOf Proposal(ProposalInit{ master: myAddress(), proposalId: self.nextProposalId }),
			body: DeployNewProposalAddr{ votingEndingAt: msg.votingEndingAt, user: sender() }.toCell(),
			mode: SendRemainingValue + SendIgnoreErrors,
			value: ton("0"),
		});
		self.nextProposalId += 1;
    }

    get fun nextProposalId(): Int {
        // TODO: implement
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


//should reimburse the excess funds sent by voters: it cannot freeze funds, burn them, or send them to someone else. 
contract Proposal {
    master: Address;
    proposalId: Int as uint32;
    yesCount: Int as uint32;
    noCount: Int as uint32;
    votingEndingAt: Int? as uint32;
    voters: map<Address, Bool>;

    init(data: ProposalInit) {
        // TODO: implement
        throwUnless(2025, data.master == sender());
        self.master = data.master;
        self.proposalId = data.proposalId;
        self.yesCount = 0;
        self.noCount = 0;
        self.voters = emptyMap();
    }

    receive(msg: DeployNewProposalAddr) {
        throwUnless(2025, self.master == sender());
        self.votingEndingAt = msg.votingEndingAt;
        cashback(msg.user);
    }

    receive(msg: Vote) {
        // TODO: implement
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
        cashback(sender());
    }

    get fun proposalState(): ProposalState {
        // TODO: implement
        return ProposalState {
            yesCount: self.yesCount,
            noCount: self.noCount,
            master: self.master,
            proposalId: self.proposalId,
            votingEndingAt: self.votingEndingAt!!
        };
    }
}

