pragma solidity >=0.5.0 <0.6.0;

import "./zombieattack.sol";
import "./erc721.sol";
import "./safemath.sol";

/// @title Zombie NFT ownership management
/// @author Ed Marcavage Thanks to Loom Network
/// @notice Manage your zombies with the power of NFTs 
/// @dev "sub-root" contract for ZombieOwnership
/// @custom: Thank You Loom Network for the awesome tutorial!

contract ZombieOwnership is ZombieAttack, ERC721 {

  using SafeMath for uint256;

  mapping (uint => address) zombieApprovals;

/// @notice see how many zombies an address has 
/// @dev index ownerZombieCount mapping with a given index 
/// @param _owner index ownerZombieCount mapping with _owner 
  function balanceOf(address _owner) external view returns (uint256) {
    return ownerZombieCount[_owner];
  }

/// @notice see who owns a zombie 
/// @dev index zombieToOwner mapping with a given zombie id 
/// @param _tokenId index zombieToOwner mapping with _tokenId 
  function ownerOf(uint256 _tokenId) external view returns (address) {
    return zombieToOwner[_tokenId];
  }

/// @notice transfer your NFT zombie 
/// @dev used by erc721 interface's transferFrom func 
/// @param _from, _to, _tokenId; transfer what NFT (tokenID) from who (_from) to who (_to)
  function _transfer(address _from, address _to, uint256 _tokenId) private { // research why create a different func in addition to transferFrom
    ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
    ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].sub(1);
    zombieToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

/// @notice transfer your NFT zombie 
/// @dev see _transfer func 
/// @param _from, _to, _tokenId; transfer what NFT (tokenID) from who (_from) to who (_to)
  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
      require (zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
      _transfer(_from, _to, _tokenId);
    }

/// @notice Approve someone and give them your NFT zombie 
/// @dev users can take NFT once approved address is indexed in zombieApprovals
/// @param _approved, _tokenId; what address (_approved) is approved for what NFT (_tokenId)
  function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
      zombieApprovals[_tokenId] = _approved;
      emit Approval(msg.sender, _approved, _tokenId);
    }

}
