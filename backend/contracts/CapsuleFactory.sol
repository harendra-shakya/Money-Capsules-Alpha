// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./ERC20Capsule.sol";
import "./NftCapsule.sol";
import "./MixedCapsule.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CapsuleFactory is Ownable {
    address private immutable erc20WalletImplementation;
    address private immutable nftWalletImplementation;
    address private immutable mixedWalletImplementation;
    uint256 private price;
    address private immutable SWAPPING_CONTRACT;
    address private immutable ASSET_REGISTRY;

    event erc20CapsuleCreation(address cloneAddress, address ownedBy);
    event nftCapsuleCreation(address cloneAddress, address ownedBy);
    event mixedCapsuleCreation(address cloneAddress, address ownedBy);

    constructor(uint256 _price, address assetRegistry, address swappingAddress) {
        price = _price;
        ASSET_REGISTRY = assetRegistry;
        SWAPPING_CONTRACT = swappingAddress;
        erc20WalletImplementation = address(new ERC20Capsule());
        nftWalletImplementation = address(new NftCapsule());
        mixedWalletImplementation = address(new MixedCapsule());
    }

    function createERC20Capsule() external {
        address clone = Clones.clone(erc20WalletImplementation);
        ERC20Capsule(clone).initialize(ASSET_REGISTRY, SWAPPING_CONTRACT);
        ERC20Capsule(clone).transferOwnership(msg.sender);
        emit erc20CapsuleCreation(clone, msg.sender);
    }

    function createNftCapsule() external {
        address clone = Clones.clone(nftWalletImplementation);
        NftCapsule(clone).initialize();
        NftCapsule(clone).transferOwnership(msg.sender);
        emit nftCapsuleCreation(clone, msg.sender);
    }

    function createMixedCapsule() external payable {
        require(msg.value >= price, "Insufficient paid amount");
        address clone = Clones.clone(mixedWalletImplementation);
        MixedCapsule(clone).initialize();
        MixedCapsule(clone).transferOwnership(msg.sender);
        emit mixedCapsuleCreation(clone, msg.sender);
    }

    function changePrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function getPrice() public view returns (uint256 _price) {
        _price = price;
    }
}
