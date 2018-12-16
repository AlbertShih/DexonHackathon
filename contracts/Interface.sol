pragma solidity ^0.4.25;

import "./Game.sol";

contract GameInterface {
    address internal owner;
    mapping(address => Game) internal gameOwnerMap;

    constructor()
    public
    {
        owner = msg.sender;
    }

    function NewGame()
    external
    payable
    {
        require (msg.value > 1 ether);
        Game g = new Game(owner);
        gameOwnerMap[msg.sender] = g;
    }

    function GetBalance()
    external
    view
    returns(uint)
    {
        return address(this).balance;
    }

    function ReceiveMoney(address _receiver)
    external
    onlyOwner
    {
        _receiver.transfer(address(this).balance);
    }

    function StopGame(address _add)
    external
    onlyOwner {
        uint256 lastUpdateTime = gameOwnerMap[_add].GetUpdateTime();
        uint256 compareTime = lastUpdateTime + 30 days;
        require (compareTime > now);
        gameOwnerMap[_add].TransferMoneyToTopOwner();
    }

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
}