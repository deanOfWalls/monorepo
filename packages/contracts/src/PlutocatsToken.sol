// SPDX-License-Identifier: GPL-3.0

/// @title Plutocats NFT

pragma solidity >=0.8.0;

import {ERC721} from "nouns-monorepo/packages/nouns-contracts/contracts/base/ERC721.sol";
import {ERC721Checkpointable} from "nouns-monorepo/packages/nouns-contracts/contracts/base/ERC721Checkpointable.sol";
import {IPlutocatsDescriptorMinimal} from "./interfaces/IPlutocatsDescriptorMinimal.sol";
import {IPlutocatsSeeder} from "./interfaces/IPlutocatsSeeder.sol";
import {IPlutocatsToken} from "./interfaces/IPlutocatsToken.sol";
import {LinearVRGDA} from "VRGDAs/LinearVRGDA.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {toDaysWadUnsafe} from "solmate/utils/SignedWadMath.sol";

contract PlutocatsToken is IPlutocatsToken, ERC721Checkpointable, LinearVRGDA, Ownable {
    using Address for address payable;

    /// Timestamp for when minting will start.
    uint256 public immutable MINT_START;

    /// The internal tokenId tracker.
    uint256 private _currentCatId;

    /// The address of the reserve.
    address public reserve;

    /// The Plutocats token URI descriptor.
    IPlutocatsDescriptorMinimal public descriptor;

    /// The Plutocats token seeder.
    IPlutocatsSeeder public seeder;

    /// Plutocat seeds.
    mapping(uint256 => IPlutocatsSeeder.Seed) public seeds;

    /// Whether to turn off dynamic book value reserve price for mints.
    bool public enableReservePrice;

    /// a mapping that records contributions to the reserve.
    mapping(uint256 => Contribution) internal contributions;

    // IPFS content hash of contract-level metadata.
    string private _contractURIHash = "TODO";

    /// Require that the sender is the reserve.
    modifier onlyReserve() {
        if (msg.sender != reserve) {
            revert OnlyReserve();
        }

        _;
    }

    /// MEOWMEOWMEOW
    constructor(uint256 _mintStart, address _reserve, address _descriptor, address _seeder, bool _enableReservePrice)
        ERC721("Plutocats", "PCAT")
        LinearVRGDA(
            1e18, // target price (1 ETH)
            0.1e18, // decay percent (10%)
            1e18 // per time unit (1 day)
        )
    {
        MINT_START = _mintStart;
        reserve = _reserve;
        descriptor = IPlutocatsDescriptorMinimal(_descriptor);
        seeder = IPlutocatsSeeder(_seeder);
        enableReservePrice = _enableReservePrice;
    }

    /// IPFS uri for contract-level metadata.
    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked("ipfs://", _contractURIHash));
    }

    /// Set the contract uri hash.
    function setContractURIHash(string memory newContractURIHash) external onlyOwner {
        _contractURIHash = newContractURIHash;
    }

    /// Mint a Plutocat to the caller.
    function mint() public payable override returns (uint256) {
        // will revert prior to mint start time, causing an underflow
        uint256 currentPrice = getPrice();

        if (currentPrice > msg.value) {
            revert InsufficientFundsProvided();
        }

        // send ETH to the reserve
        payable(reserve).sendValue(msg.value);
        emit ETHSent(reserve, msg.value);

        return mintToInternal(msg.sender, _currentCatId++);
    }

    /// Get the current price of the next Plutocat to be minted. Enforces a minimum price
    /// of reserve book value. (reserveBalance / adjustedTotalSupply).
    function getPrice() public view returns (uint256) {
        // checked math will cause underflow to prevent mints before start time
        uint256 timeSinceStart = block.timestamp - MINT_START;
        uint256 vrgdaPrice = getVRGDAPrice(toDaysWadUnsafe(timeSinceStart), _currentCatId);
        uint256 minPrice = vrgdaPrice;
        uint256 adjTotalSupply = adjustedTotalSupply();

        /// dynamic reserve price based off book value
        if (enableReservePrice && adjTotalSupply > 0) {
            minPrice = reserve.balance / adjTotalSupply;
        }

        // enforce minimum price on membership
        if (vrgdaPrice < minPrice) {
            return minPrice;
        }

        return vrgdaPrice;
    }

    /// Mint a Plutocat with id to the provided address.
    function mintToInternal(address _to, uint256 _catId) internal returns (uint256) {
        IPlutocatsSeeder.Seed memory seed = seeds[_catId] = seeder.generateSeed(_catId, descriptor);

        _mint(address(0), _to, _catId);
        contributions[_catId] = Contribution({amount: msg.value, joinTime: block.timestamp});

        emit PlutocatPurchased(_catId, msg.value, seed);

        return _catId;
    }

    /// A distinct URI for the given token.
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        if (!_exists(_tokenId)) {
            revert TokenDoesNotExist();
        }

        return descriptor.tokenURI(_tokenId, seeds[_tokenId]);
    }

    /// Similar to tokenURI but always returns a base64 encoded data URI.
    function dataURI(uint256 _tokenId) public view override returns (string memory) {
        if (!_exists(_tokenId)) {
            revert TokenDoesNotExist();
        }

        return descriptor.dataURI(_tokenId, seeds[_tokenId]);
    }

    /// Get the adjusted total supply of the contract.
    /// Does not include cats that have quit the club or have been burned.
    function adjustedTotalSupply() public view returns (uint256) {
        return totalSupply() - balanceOf(address(reserve));
    }

    /// Get total contributions of a member to the reserve.
    function contributionsOf(uint256 _tokenId) external view returns (Contribution memory) {
        return contributions[_tokenId];
    }

    /// Set the Plutocats token URI descriptor.
    function setDescriptor(address _descriptor) external onlyOwner {
        descriptor = IPlutocatsDescriptorMinimal(_descriptor);
        emit DescriptorUpdated(_descriptor);
    }

    /// Set the Plutocats token seeder.
    function setSeeder(address _seeder) external onlyOwner {
        seeder = IPlutocatsSeeder(_seeder);
        emit SeederUpdated(_seeder);
    }

    /// Set whether dynamic reserve price is enabled on mints.
    function setReservePrice(bool _enableReservePrice) external onlyOwner {
        enableReservePrice = _enableReservePrice;
        emit ReservePriceSet(_enableReservePrice);
    }
}