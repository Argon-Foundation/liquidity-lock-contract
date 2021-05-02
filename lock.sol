pragma solidity ^0.4.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract lock {
    struct lockInfo {
        uint256 startedDate;
        uint256 endDate;
        uint256 amount;
        address tokenAddress;
        address managerAddress;
    }

    uint256 public poolCount = 0;
    lockInfo public pool;

    modifier onlyManager() {
        require(msg.sender == pool.managerAddress);
        _;
    }

    function lockTokens(
        uint256 _endDate,
        uint256 _amount,
        address _tokenAddress
    ) public {
        require(now < _endDate, "endDate should be smaller than now");
        require(_amount != 0, "amount cannot 0");
        require(
            _tokenAddress != address(0),
            "Token adress cannot be address(0)"
        );
        require(
            IERC20(_tokenAddress).transferFrom(
                msg.sender,
                address(this),
                _amount
            ),
            "Transaction failed"
        );
        require(poolCount == 0, "Pool count must be 0");
        pool = lockInfo(now, _endDate, _amount, _tokenAddress, msg.sender);
        poolCount++;
    }

    function getPoolData()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            address
        )
    {
        return (
            pool.startedDate,
            pool.endDate,
            pool.amount,
            pool.tokenAddress,
            pool.managerAddress
        );
    }

    function getTokens() public onlyManager {
        require(now > pool.endDate);
        IERC20(pool.tokenAddress).transfer(msg.sender, pool.amount);
    }
}
