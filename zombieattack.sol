pragma solidity >=0.5.0 <0.6.0;

import "./zombiehelper.sol";

/// @title Zombie Battle Contract 
/// @author Ed Marcavage Thanks to Loom Network
/// @notice Attack other zombies with a 70% chance of winning 
/// @dev "sub-root" contract for ZombieOwnership
/// @custom: Thank You Loom Network for the awesome tutorial!

contract ZombieAttack is ZombieHelper {
  uint randNonce = 0;
  uint attackVictoryProbability = 70;

/// @dev Secure randomness except agaisnt a dishonest node
/// @param _modulus denominator of probality of winning ex. 70/_modulus; if _modulus = 100; p = 70% 

  function randMod(uint _modulus) internal returns(uint) {
    randNonce = randNonce.add(1);
    return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
  }

/// @notice attacking zombie wins 70% of the time, coolDown triggered regardless of W or L 
/// @dev control probablity with attackVictoryProbability uint 
/// @param _zombieId, _targetId; serilaized values for competing zombies 
  function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {
    Zombie storage myZombie = zombies[_zombieId];
    Zombie storage enemyZombie = zombies[_targetId];
    uint rand = randMod(100);
    if (rand <= attackVictoryProbability) {
      myZombie.winCount = myZombie.winCount.add(1);
      myZombie.level = myZombie.level.add(1);
      enemyZombie.lossCount = enemyZombie.lossCount.add(1);
      feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
    } else {
      myZombie.lossCount = myZombie.lossCount.add(1);
      enemyZombie.winCount = enemyZombie.winCount.add(1);
      _triggerCooldown(myZombie);
    }
  }
}
