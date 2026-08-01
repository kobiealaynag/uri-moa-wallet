// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20Lite {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract SharedVault {
    struct Payout {
        address requester;
        address recipient;
        uint256 amount;
        string purpose;
        bool approved;
        bool executed;
        bool rejected;
    }

    address public owner;
    address public token;
    string public name;
    uint256 public dailyLimit;
    uint256 public largeThreshold;
    uint256 public payoutCount;
    uint256 public reservedBalance;
    bool public settled;

    mapping(address => bool) public admins;
    mapping(address => bool) public isMember;
    mapping(address => bool) public pendingInvites;
    mapping(address => bool) public pendingInviteAdmin;
    mapping(address => uint256) public deposits;
    mapping(uint256 => Payout) public payouts;
    address[] private members;

    event MemberInvited(address indexed member, bool admin);
    event MemberAccepted(address indexed member, bool admin);
    event MemberRemoved(address indexed member);
    event Deposited(address indexed member, uint256 amount);
    event PayoutRequested(uint256 indexed id, address indexed requester, address indexed recipient, uint256 amount, string purpose);
    event PayoutApproved(uint256 indexed id, address indexed admin);
    event PayoutRejected(uint256 indexed id, address indexed admin);
    event PayoutExecuted(uint256 indexed id, address indexed recipient, uint256 amount);
    event SettledEqual(address indexed caller, uint256 amountPerMember);

    modifier onlyAdmin() {
        require(msg.sender == owner || admins[msg.sender], "NOT_ADMIN");
        _;
    }

    modifier onlyParticipant() {
        require(msg.sender == owner || isMember[msg.sender], "NOT_PARTICIPANT");
        _;
    }

    constructor(string memory vaultName, address token_, address owner_, uint256 dailyLimit_, uint256 largeThreshold_) {
        name = vaultName;
        token = token_;
        owner = owner_;
        dailyLimit = dailyLimit_;
        largeThreshold = largeThreshold_;
        admins[owner_] = true;
        isMember[owner_] = true;
    }

    function inviteMember(address member, bool makeAdmin) external {
        require(msg.sender == owner, "NOT_OWNER");
        require(member != address(0) && member != owner, "INVALID_MEMBER");
        require(!isMember[member], "ALREADY_MEMBER");
        require(!pendingInvites[member], "ALREADY_INVITED");
        pendingInvites[member] = true;
        pendingInviteAdmin[member] = makeAdmin;
        emit MemberInvited(member, makeAdmin);
    }

    function acceptInvite() external {
        require(pendingInvites[msg.sender], "NO_INVITE");
        bool makeAdmin = pendingInviteAdmin[msg.sender];
        pendingInvites[msg.sender] = false;
        pendingInviteAdmin[msg.sender] = false;
        isMember[msg.sender] = true;
        admins[msg.sender] = makeAdmin;
        members.push(msg.sender);
        emit MemberAccepted(msg.sender, makeAdmin);
    }

    function setAdmin(address member, bool enabled) external {
        require(msg.sender == owner, "NOT_OWNER");
        require(isMember[member], "NOT_MEMBER");
        admins[member] = enabled;
    }

    function getMembers() external view returns (address[] memory) {
        return members;
    }

    function deposit(uint256 amount) external onlyParticipant {
        require(!settled, "VAULT_SETTLED");
        require(amount > 0, "ZERO_AMOUNT");
        require(IERC20Lite(token).transferFrom(msg.sender, address(this), amount), "TRANSFER_FROM");
        deposits[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
    }

    function availableBalance() public view returns (uint256) {
        uint256 balance = IERC20Lite(token).balanceOf(address(this));
        return balance > reservedBalance ? balance - reservedBalance : 0;
    }

    function requestPayout(address recipient, uint256 amount, string calldata purpose) external onlyParticipant returns (uint256 id) {
        require(!settled, "VAULT_SETTLED");
        require(amount > 0, "ZERO_AMOUNT");
        require(recipient != address(0), "ZERO_RECIPIENT");
        require(amount <= availableBalance(), "INSUFFICIENT_AVAILABLE_BALANCE");
        reservedBalance += amount;
        id = payoutCount++;
        payouts[id] = Payout(msg.sender, recipient, amount, purpose, false, false, false);
        emit PayoutRequested(id, msg.sender, recipient, amount, purpose);
    }

    function approvePayout(uint256 id) external onlyAdmin {
        Payout storage p = payouts[id];
        require(!p.executed && !p.rejected, "PAYOUT_CLOSED");
        p.approved = true;
        emit PayoutApproved(id, msg.sender);
        _executePayout(id);
    }

    function rejectPayout(uint256 id) external onlyAdmin {
        Payout storage p = payouts[id];
        require(!p.executed && !p.rejected, "PAYOUT_CLOSED");
        p.rejected = true;
        reservedBalance -= p.amount;
        emit PayoutRejected(id, msg.sender);
    }

    function settleEqual() external onlyAdmin {
        require(!settled, "VAULT_SETTLED");
        require(reservedBalance == 0, "PENDING_PAYOUTS");
        settled = true;
        uint256 participantCount = members.length + 1;
        uint256 bal = IERC20Lite(token).balanceOf(address(this));
        uint256 each = bal / participantCount;
        uint256 ownerAmount = bal - (each * members.length);
        require(IERC20Lite(token).transfer(owner, ownerAmount), "OWNER_TRANSFER");
        for (uint256 i = 0; i < members.length; i++) {
            require(IERC20Lite(token).transfer(members[i], each), "MEMBER_TRANSFER");
        }
        emit SettledEqual(msg.sender, each);
    }

    function _executePayout(uint256 id) internal {
        Payout storage p = payouts[id];
        require(!p.executed, "EXECUTED");
        require(p.approved, "NEEDS_APPROVAL");
        p.executed = true;
        reservedBalance -= p.amount;
        require(IERC20Lite(token).transfer(p.recipient, p.amount), "TRANSFER");
        emit PayoutExecuted(id, p.recipient, p.amount);
    }
}

contract SharedVaultFactory {
    event VaultCreated(address indexed vault, address indexed owner, string name);

    address[] public vaults;

    function createVault(string calldata name, address token, uint256 dailyLimit, uint256 largeThreshold) external returns (address vault) {
        vault = address(new SharedVault(name, token, msg.sender, dailyLimit, largeThreshold));
        vaults.push(vault);
        emit VaultCreated(vault, msg.sender, name);
    }
}
