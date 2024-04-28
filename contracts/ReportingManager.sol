// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract ReportingManager {
    mapping(address => bool) public _moderators;
    address _owner;

    event ModeratorAdded(address moderator);
    event ModeratorRemoved(address moderator);

    modifier onlyOwner() {
        require(_owner == msg.sender, "Not authorized");
        _;
    }

    function _addModerator(address moderator) external{
        require(moderator != address(0), "Cannot add zero address");
        _moderators[moderator] = true;

        emit ModeratorAdded(moderator);
    }

    function _removeModerator(address moderator) external{
        require(_moderators[moderator], "Address is not a moderator");
        _moderators[moderator] = false;

        emit ModeratorRemoved(moderator);
    }

    function _isModerator(address addressToCheck) external view returns(bool) {
        require(addressToCheck != address(0), "Cannot check zero address");

        return _moderators[addressToCheck];
    }

    function _setOwner(address owner) external{
        require(owner != address(0), "Cannot add zero address");
        _owner = owner;
    }
}
