// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/SignedMath.sol";

interface IReportingManager {
    function _addModerator(address) external;
    function _removeModerator(address) external;
    function _isModerator(address) external view returns(bool);
    function _setOwner(address) external;
}
