pragma solidity >=0.5.0 <0.6.0;

import "./ownable.sol";
import "./safemath.sol";

/// @title Zombie Generation Factory
/// @author Ed Marcavage Thanks to Loom Network
/// @notice You can use this contract for only the most basic simulation
/// @dev "root" contract for ZombieFeeding, ZombieHelper, ZombieAttack, and ZombieOwnership
/// @custom: Thank You Loom Network for the awesome tutorial! 
contract ZombieFactory is Ownable {

  using SafeMath for uint256;
  using SafeMath32 for uint32;
  using SafeMath16 for uint16;

    ///@dev event subscribed in index.html
  event NewZombie(uint zombieId, string name, uint dna);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint cooldownTime = 1 days;

  struct Zombie {
    string name;
    uint dna;
    uint32 level;
    uint32 readyTime;
    uint16 winCount;
    uint16 lossCount;
  }
    /// @notice Array holding Zombie structs (above) 
    /// @dev pushes Zombie struct with given values to zombies array and indexed zombie with id 
  Zombie[] public zombies;

  ///@dev indexed zombies IDs to owners address
  mapping (uint => address) public zombieToOwner;

///@dev indexed user addresses to their count of owned zombies 
  mapping (address => uint) ownerZombieCount;

    /// @notice Creates a zombie with a given name and number for DNA 
    /// @dev cooldownTime var stored in ________
    /// @param _name and _dna init Zombie creation 
  function _createZombie(string memory _name, uint _dna) internal {
    uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
    zombieToOwner[id] = msg.sender;
    ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
    emit NewZombie(id, _name, _dna);
  }
    /// @notice generates a random number based off of a word
    /// @dev rand % dnaModulus standardizes the DNA int's length 
    /// @param _str the word used to init the random number generator 
    /// @return random number with a standardized length 
  function _generateRandomDna(string memory _str) private view returns (uint) {
    uint rand = uint(keccak256(abi.encodePacked(_str)));
    return rand % dnaModulus;
  }

    /// @notice Requires user to have 0 zombies, Uses your zombies name to create random DNA
    /// @dev ensures the user calling the functions has 0 zombies via indexing the ownerZombieCount mapping 
    /// @param _name the name used to init the random number generator for DNA and zombie characterisitics
  function createRandomZombie(string memory _name) public {
    require(ownerZombieCount[msg.sender] == 0);
    uint randDna = _generateRandomDna(_name);
    randDna = randDna - randDna % 100;
    _createZombie(_name, randDna);
  }

}
