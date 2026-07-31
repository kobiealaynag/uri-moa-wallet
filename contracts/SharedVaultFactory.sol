// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20Lite {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract SharedVault {
    struct Payout {
        address recipient;
        uint256 amount;
        string purpose;
        bool approved;
        bool executed;
    }

    address public owner;
    address public token;
    string public name;
    uint256 public dailyLimit;
    uint256 public largeThreshold;
    uint256 public payoutCount;

    mapping(address => bool) public admins;
    mapping(address => uint256) public deposits;
    mapping(uint256 => Payout) public payouts;

    event Deposited(address indexed member, uint256 amount);
    event PayoutRequested(uint256 indexed id, address indexed recipient, uint256 amount, string purpose);
    event PayoutApproved(uint256 indexed id, address indexed admin);
    event PayoutExecuted(uint256 indexed id, address indexed recipient, uint256 amount);
    event SettledEqual(address indexed caller, uint256 amountPerMember);

    modifier onlyAdmin() {
        require(msg.sender == owner || admins[msg.sender], "NOT_ADMIN");
        _;
    }

    constructor(string memory vaultName, address token_, address owner_, uint256 dailyLimit_, uint256 largeThreshold_) {
        name = vaultName;
        token = token_;
        owner = owner_;
        dailyLimit = dailyLimit_;
        largeThreshold = largeThreshold_;
        admins[owner_] = true;
    }

    function setAdmin(address admin, bool enabled) external {
        require(msg.sender == owner, "NOT_OWNER");
        admins[admin] = enabled;
    }

    function deposit(uint256 amount) external {
        require(IERC20Lite(token).transferFrom(msg.sender, address(this), amount), "TRANSFER_FROM");
        deposits[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
    }

    function requestPayout(address recipient, uint256 amount, string calldata purpose) external returns (uint256 id) {
        require(amount > 0, "ZERO_AMOUNT");
        id = payoutCount++;
        payouts[id] = Payout(recipient, amount, purpose, false, false);
        emit PayoutRequested(id, recipient, amount, purpose);
        if (amount <= dailyLimit) {
            _executePayout(id);
        }
    }

    function approvePayout(uint256 id) external onlyAdmin {
        Payout storage p = payouts[id];
        require(!p.executed, "EXECUTED");
        p.approved = true;
        emit PayoutApproved(id, msg.sender);
        _executePayout(id);
    }

    function settleEqual(address[] calldata members) external onlyAdmin {
        require(members.length > 0, "NO_MEMBERS");
        uint256 bal = MockBalance(token).balanceOf(address(this));
        uint256 each = bal / members.length;
        for (uint256 i = 0; i < members.length; i++) {
            require(IERC20Lite(token).transfer(members[i], each), "TRANSFER");
        }
        emit SettledEqual(msg.sender, each);
    }

    function _executePayout(uint256 id) internal {
        Payout storage p = payouts[id];
        require(!p.executed, "EXECUTED");
        require(p.amount <= dailyLimit || p.approved, "NEEDS_APPROVAL");
        p.executed = true;
        require(IERC20Lite(token).transfer(p.recipient, p.amount), "TRANSFER");
        emit PayoutExecuted(id, p.recipient, p.amount);
    }
}

interface MockBalance {
    function balanceOf(address account) external view returns (uint256);
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
