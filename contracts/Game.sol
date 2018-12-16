pragma solidity ^0.4.25;

contract Game {
    address internal owner;
    address topOwner;
    // 每次AddQAToUnassignList都會加1, 是唯一的.
    uint internal countQA = 0;
    uint256 updateTime;

    struct qaStruct {
        uint uuid;
        string ipfsLink;    // ipfs link
        bytes32 answerHash;
        address ownerAbleToAnser;
        uint256 assignTime;
        uint reward;
    }

    qaStruct[] unassignList;
    // id to qa
    mapping (uint => qaStruct) assignedMap;
    // 記住哪個index的question要被從unassignList拿掉.
    mapping (uint => bool) readyToAssignIndexMap;
    // who owns which IDS
    mapping (address => uint[]) whoOwnIDsMap;

    uint feeToOwnAQuestion = 1;
    uint feeToAnsAQuestion = 0;
    uint rewardOfCorrectAnser = 3;

    constructor(address _topOwner)
    public
    {
        owner = msg.sender;
        topOwner = _topOwner;
    }

    function AddQAToUnassignList(string _ipfsLink, bytes32 _answerHash, uint _reward)
    external
    payable
    onlyOwner
    {
        require(msg.value >= _reward);

        countQA += 1;
        // qaStruct qa = qaStruct({uuid: countQA, ipfsLink: _ipfsLink, answerHash: _answerHash, ownerAbleToAnser: 0, assignTime: 0, reward: _reward});
        qaStruct storage qa; 
        qa.uuid = countQA;
        qa.ipfsLink = _ipfsLink;
        qa.answerHash = _answerHash;
        qa.reward = _reward;
        qa.assignTime = 0;

        unassignList.push(qa);
        updateTime = now;
    }

    function PlayAndOwnQues(uint _numOfQuesToSolve)
    external
    returns (uint[]) // 回傳的question的unique ID. 不是 index.
    {
        // 變成廠商要付錢
        uint totalFee = feeToOwnAQuestion * _numOfQuesToSolve;
        require (address(owner).balance >= totalFee);
        topOwner.transfer(totalFee);

        uint iniUnassignLen = unassignList.length;
        uint256 nowTime = now;

        while (whoOwnIDsMap[msg.sender].length != _numOfQuesToSolve) {
            // 這個是index
            uint randNum = rand % iniUnassignLen;
            // 這個是ID
            uint id = unassignList[randNum].uuid;
            if (readyToAssignIndexMap[randNum]) {
                continue;
            }

            readyToAssignIndexMap[randNum] = true;
            whoOwnIDsMap[msg.sender].push(id);

            qaStruct storage readyToAssignQA = unassignList[randNum];
            readyToAssignQA.assignTime = nowTime;
            readyToAssignQA.ownerAbleToAnser = msg.sender;
            assignedMap[id] = readyToAssignQA;
        }

        qaStruct[] storage unassignListTarget;// = new qaStruct[iniUnassignLen - _numOfQuesToSolve];
        for(uint i = 0; i < iniUnassignLen; i++) {
            if (readyToAssignIndexMap[i]) {
                // 有找到表示要被移出unassignList.
                continue;
            }
            // 沒有找到表示留在unassignList.
            unassignListTarget.push(unassignList[i]);
        }    
        unassignList = unassignListTarget;
        
        updateTime = now;
        return whoOwnIDsMap[msg.sender];
    }

    function SubmitAnser(uint _quesID, bytes32 _ansHash)
    external
    payable
    returns (bool)
    {
        // require(msg.sender == tx.origin);
        // Check user is the question owner able to provide anser
        require(assignedMap[_quesID].ownerAbleToAnser == msg.sender);
        if (assignedMap[_quesID].assignTime + 10 minutes < now) {
            // 失效了回去Unassign
            addAssignToUnassign(_quesID);
            return false;
        }

        // If the anwser is correct and there is enough fee to provide anser, transfer the money
        if(assignedMap[_quesID].answerHash == _ansHash) // TBD, Add unit
        {
            require(address(this).balance > rewardOfCorrectAnser);   //TBD, will this happen?
            require(assignedMap[_quesID].reward <= address(owner).balance);
            msg.sender.transfer(assignedMap[_quesID].reward);

            return true;
        }
        updateTime = now;
        return false;
    }

    function TransferMoneyToTopOwner()
    external
    onlyTopOwner
    {
        topOwner.transfer(address(this).balance);
    }

    function GetUpdateTime()
    external
    view
    returns (uint256)
    {
        return updateTime;
    }

    function addAssignToUnassign(uint _quesID)
    internal
    {
        qaStruct storage qa = assignedMap[_quesID];
        delete(assignedMap[_quesID]);
        unassignList.push(qa);
    }

    // TODO: whoOwnIDsMap 要clear之類的
    // TBD: Timeout will return 1 feeToOwnAQuestion - Gas fee
    // function AnwserTimeout() external
    // {

    // }

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    modifier onlyTopOwner() {
        require(topOwner == msg.sender);
        _;
    }
}