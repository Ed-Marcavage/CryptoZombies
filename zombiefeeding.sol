pragma solidity >=0.5.0 <0.6.0;

import "./zombiefactory.sol";

/// @title Interface for CryptoKitties Smart contract
/// @dev Major purpose; feedOnKitty func 
/// @custom: Thank You Loom Network for the awesome tutorial!

contract KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

/// @title Zombie regeneration and managing zombie repopulation
/// @author Ed Marcavage Thanks to Loom Network
/// @notice Eat other Zombies or crypto cats! 
/// @dev "sub-root" contract for ZombieHelper, ZombieAttack, and ZombieOwnership
/// @custom: Thank You Loom Network for the awesome tutorial!

contract ZombieFeeding is ZombieFactory {

  KittyInterface kittyContract;

/// @dev ensures function caller is linked to _zombieId in zombieToOwner mapping (is the owner)
/// @param _zombieId look up key in zombieToOwner mapping 
  modifier onlyOwnerOf(uint _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]);
    _;
  }

/// @dev sets kittyContract object to given address
/// @param _address of the crypto kitties contract
  function setKittyContractAddress(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }

/// @dev adds cooldownTime to current unix time to control zombie repop.
/// @param _zombie storage poiner in zombies array; _zombie = zombies[_zombieId];
  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime);
  }

/// @dev checks if zombie is abiding to _triggerCooldown (to control zombie repop.) 
/// @param _zombie storage poiner in zombies array; _zombie = zombies[_zombieId];
  function _isReady(Zombie storage _zombie) internal view returns (bool) {
      return (_zombie.readyTime <= now);
  }

/// @dev new zombie is a DNA 'average' of the 2, kitty zombies DNA end with 99
/// @param _zombieId, _targetDna, _species contribute to new zombie DNA
  function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal onlyOwnerOf(_zombieId) {
    Zombie storage myZombie = zombies[_zombieId];
    require(_isReady(myZombie));
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);
    _triggerCooldown(myZombie);
  }

/// @dev calls on kittyContract instance and calls getKitty func...only need the kittyDNA var
/// @param _zombieId, _kittyId interacts with kittyContract interface to get kitty characteristics 

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}
