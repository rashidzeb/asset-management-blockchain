// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

error AssetPool__NotAdmin();
error AssetPool__FundsAlreadyInvested();
error AssetPool__NotEnoughBalanceInContract();

contract AssetPool {
    address[] private clients;
    Asset[] private assetsArr;
    address private immutable i_admin;
    mapping(address => uint256) private addressToAmount;
    mapping(address => uint256) private addressToInvestment;
    mapping(address => bool) private investmentFlag;

    struct Asset {
        uint256 id;
        string assetPrice;
        string title;
        string location;
    }

    modifier administrator() {
        if (msg.sender != i_admin) {
            revert AssetPool__NotAdmin();
        }
        _;
    }

    modifier investmentStatus() {
        if (investmentFlag[msg.sender] != false) {
            revert AssetPool__FundsAlreadyInvested();
        }
        _;
    }

    modifier checkContractBalance() {
        if (address(this).balance < 1e16) {
            revert AssetPool__NotEnoughBalanceInContract();
        }
        _;
    }

    constructor() {
        i_admin = msg.sender;
    }

    receive() external payable {
        depositFund();
    }

    fallback() external payable {
        depositFund();
    }

    function depositFund() public payable {
        require(msg.value >= 1e16, "You need to deposit at least 0.01 Eth");
        clients.push(msg.sender);
        addressToAmount[msg.sender] += msg.value;
        investmentFlag[msg.sender] = false;
    }

    function invest() public investmentStatus {
        require(addressToAmount[msg.sender] >= 1e16, "Funds too low to invest");
        investmentFlag[msg.sender] = true;
        addressToInvestment[msg.sender] += addressToAmount[msg.sender];
        addressToAmount[msg.sender] = 0;
    }

    function withdraw(uint256 _withdrawAmount)
        public
        investmentStatus
        checkContractBalance
    {
        require(
            _withdrawAmount <= addressToAmount[msg.sender],
            "You don't have enough balance"
        );
        addressToAmount[msg.sender] -= _withdrawAmount;
        (bool callSuccess, ) = payable(msg.sender).call{value: _withdrawAmount}(
            ""
        );
        require(callSuccess, "Call Failed");
    }

    function withdrawContractFunds() public administrator checkContractBalance {
        (bool callSuccess, ) = i_admin.call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    function createAsset(
        string memory _assetPrice,
        string memory _title,
        string memory _location
    ) public administrator {
        Asset memory asset;

        asset.id = assetsArr.length;
        asset.assetPrice = _assetPrice;
        asset.title = _title;
        asset.location = _location;

        assetsArr.push(asset);
    }

    function getAsset(uint256 _id)
        public
        view
        returns (
            uint256,
            string memory,
            string memory,
            string memory
        )
    {
        uint256 index = _id;
        return (
            assetsArr[index].id,
            assetsArr[index].assetPrice,
            assetsArr[index].title,
            assetsArr[index].location
        );
    }

    function getMyBalance() public view returns (uint256) {
        return addressToAmount[msg.sender];
    }

    function getInvestedAmount() public view returns (uint256) {
        return addressToInvestment[msg.sender];
    }

    function getInvestmentStatus() public view returns (bool) {
        return investmentFlag[msg.sender];
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function isAdmin() public view returns (bool) {
        if (msg.sender == i_admin) {
            return true;
        } else {
            return false;
        }
    }
}
