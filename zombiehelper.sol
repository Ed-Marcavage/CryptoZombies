pragma solidity >=0.5.0 <0.6.0;

import "./zombiefeeding.sol";

/// @title Zombie characteristic management 
/// @author Ed Marcavage Thanks to Loom Network
/// @notice Edit and manage your zombies characteristic
/// @dev "sub-root" contract for ZombieAttack, and ZombieOwnership
/// @custom: Thank You Loom Network for the awesome tutorial!

contract ZombieHelper is ZombieFeeding {

  uint levelUpFee = 0.001 ether;

/// @notice Ensures your zombie meets a given level requirement 
/// @param _level, _zombieId used to search and check if zombie meets the level requirement
  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }

/// @dev owner() is owners address, as seen in ownable.sol
  function withdraw() external onlyOwner {
    address _owner = owner();
    _owner.transfer(address(this).balance); //balance of this smart contract, w/o this func, withdraw is not possible
  }


/// @dev first line under contract creation - fee declared 0.001 ETH 
/// @param _fee is the fee or cost in crease a zombie's level w/o attacking and winning 
  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

/// @dev set fee with setLevelUpFee func
/// @param _zombieId used to locate Zombie struct in zombies array 
  function levelUp(uint _zombieId) external payable {
    require(msg.value == levelUpFee);
    zombies[_zombieId].level = zombies[_zombieId].level.add(1);
  }

/// @dev customize level required in aboveLevel modifier
/// @param _zombieId locates zombie to switch .name to given _newName
  function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].name = _newName;
  }

/// @dev basically identical to changeName functionality 
/// @param _zombieId locates zombie to switch .name to given _newDna
  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].dna = _newDna;
  }

/// @dev external view avoids gas and momory is chaper than storage 
/// @param _zombieId locates zombie to switch .name to given _newDna
  function getZombiesByOwner(address _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner) { // iterate all address in mapping and compare to _owner address 
        result[counter] = i; // Need to d additional research, ios this appending to array? 
        counter++;
      }
    }
    return result;
  }

}
