// SPDX-License-Identifier: GPL-3.0

/// @title Plutocats NFT Descriptor
/// Includes modifications for new traits
/// Based on Nouns https://github.com/nounsDAO/nouns-monorepo/blob/master/packages/nouns-contracts/contracts/NounsDescriptorV2.sol

pragma solidity >=0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {NFTDescriptorV2} from "nouns-monorepo/packages/nouns-contracts/contracts/libs/NFTDescriptorV2.sol";
import {ISVGRenderer} from "nouns-monorepo/packages/nouns-contracts/contracts/interfaces/ISVGRenderer.sol";
import {IPlutocatsArt} from "./interfaces/IPlutocatsArt.sol";
import {IPlutocatsDescriptor} from "./interfaces/IPlutocatsDescriptor.sol";
import {IPlutocatsSeeder} from "./interfaces/IPlutocatsSeeder.sol";
import {IInflator} from "nouns-monorepo/packages/nouns-contracts/contracts/interfaces/IInflator.sol";

contract PlutocatsDescriptor is IPlutocatsDescriptor, Ownable {
    using Strings for uint256;

    // https://creativecommons.org/publicdomain/zero/1.0/legalcode.txt
    // solhint-disable-next-line
    bytes32 constant COPYRIGHT_CC0_1_0_UNIVERSAL_LICENSE =
        0xa2010f343487d3f7618affe54f789f5487602331c0a8d03f49e9a7c547cf0499;

    /// @notice The contract responsible for holding compressed art
    IPlutocatsArt public art;

    /// @notice The contract responsible for constructing SVGs
    ISVGRenderer public renderer;

    /// @notice Whether or not new parts can be added
    bool public override arePartsLocked;

    /// @notice Whether or not `tokenURI` should be returned as a data URI (Default: true)
    bool public override isDataURIEnabled = true;

    /// @notice Base URI, used when isDataURIEnabled is false
    string public override baseURI;

    /**
     * @notice Require that the parts have not been locked.
     */
    modifier whenPartsNotLocked() {
        require(!arePartsLocked, "Parts are locked");
        _;
    }

    constructor(IPlutocatsArt _art, ISVGRenderer _renderer) {
        art = _art;
        renderer = _renderer;
    }

    /**
     * @notice Set the art contract.
     * @dev Only callable by the owner when not locked.
     */
    function setArt(IPlutocatsArt _art) external onlyOwner whenPartsNotLocked {
        art = _art;

        emit ArtUpdated(_art);
    }

    /**
     * @notice Set the SVG renderer.
     * @dev Only callable by the owner.
     */
    function setRenderer(ISVGRenderer _renderer) external onlyOwner {
        renderer = _renderer;

        emit RendererUpdated(_renderer);
    }

    /**
     * @notice Set the art contract's `descriptor`.
     * @param descriptor the address to set.
     * @dev Only callable by the owner.
     */
    function setArtDescriptor(address descriptor) external onlyOwner {
        art.setDescriptor(descriptor);
    }

    /**
     * @notice Set the art contract's `inflator`.
     * @param inflator the address to set.
     * @dev Only callable by the owner.
     */
    function setArtInflator(IInflator inflator) external onlyOwner {
        art.setInflator(inflator);
    }

    /**
     * @notice Get the number of available `backgrounds`.
     */
    function backgroundCount() external view override returns (uint256) {
        return art.backgroundCount();
    }

    /**
     * @notice Get the number of available `bodies`.
     */
    function bodyCount() external view override returns (uint256) {
        return art.bodyCount();
    }

    /**
     * @notice Get the number of available `accessories`.
     */
    function accessoryCount() external view override returns (uint256) {
        return art.accessoryCount();
    }

    /**
     * @notice Get the number of available `heads`.
     */
    function headCount() external view override returns (uint256) {
        return art.headCount();
    }

    /**
     * @notice Get the number of available `eyes`.
     */
    function eyesCount() external view returns (uint256) {
        return art.eyesCount();
    }

    /**
     * @notice Get the number of available `glasses`.
     */
    function glassesCount() external view override returns (uint256) {
        return art.glassesCount();
    }

    /**
     * @notice Batch add backgrounds.
     * @dev This function can only be called by the owner when not locked.
     */
    function addManyBackgrounds(string[] calldata _backgrounds) external override onlyOwner whenPartsNotLocked {
        art.addManyBackgrounds(_backgrounds);
    }

    /**
     * @notice Add a background.
     * @dev This function can only be called by the owner when not locked.
     */
    function addBackground(string calldata _background) external override onlyOwner whenPartsNotLocked {
        art.addBackground(_background);
    }

    /**
     * @notice Update a single color palette. This function can be used to
     * add a new color palette or update an existing palette.
     * @param paletteIndex the identifier of this palette
     * @param palette byte array of colors. every 3 bytes represent an RGB color. max length: 256 * 3 = 768
     * @dev This function can only be called by the owner when not locked.
     */
    function setPalette(uint8 paletteIndex, bytes calldata palette) external override onlyOwner whenPartsNotLocked {
        art.setPalette(paletteIndex, palette);
    }

    /**
     * @notice Add a batch of body images.
     * @param encodedCompressed bytes created by taking a string array of RLE-encoded images, abi encoding it as a bytes array,
     * and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches.
     * @dev This function can only be called by the owner when not locked.
     */
    function addBodies(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyOwner
        whenPartsNotLocked
    {
        art.addBodies(encodedCompressed, decompressedLength, imageCount);
    }

    /**
     * @notice Add a batch of accessory images.
     * @param encodedCompressed bytes created by taking a string array of RLE-encoded images, abi encoding it as a bytes array,
     * and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches.
     * @dev This function can only be called by the owner when not locked.
     */
    function addAccessories(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyOwner
        whenPartsNotLocked
    {
        art.addAccessories(encodedCompressed, decompressedLength, imageCount);
    }

    /**
     * @notice Add a batch of head images.
     * @param encodedCompressed bytes created by taking a string array of RLE-encoded images, abi encoding it as a bytes array,
     * and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches.
     * @dev This function can only be called by the owner when not locked.
     */
    function addHeads(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyOwner
        whenPartsNotLocked
    {
        art.addHeads(encodedCompressed, decompressedLength, imageCount);
    }

    /**
     * @notice Add a batch of eyes images.
     * @param encodedCompressed bytes created by taking a string array of RLE-encoded images, abi encoding it as a bytes array,
     * and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches.
     * @dev This function can only be called by the owner when not locked.
     */
    function addEyes(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyOwner
        whenPartsNotLocked
    {
        art.addEyes(encodedCompressed, decompressedLength, imageCount);
    }

    /**
     * @notice Add a batch of glasses images.
     * @param encodedCompressed bytes created by taking a string array of RLE-encoded images, abi encoding it as a bytes array,
     * and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches.
     * @dev This function can only be called by the owner when not locked.
     */
    function addGlasses(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyOwner
        whenPartsNotLocked
    {
        art.addGlasses(encodedCompressed, decompressedLength, imageCount);
    }

    /**
     * @notice Update a single color palette. This function can be used to
     * add a new color palette or update an existing palette. This function does not check for data length validity
     * (len <= 768, len % 3 == 0).
     * @param paletteIndex the identifier of this palette
     * @param pointer the address of the contract holding the palette bytes. every 3 bytes represent an RGB color.
     * max length: 256 * 3 = 768.
     * @dev This function can only be called by the owner when not locked.
     */
    function setPalettePointer(uint8 paletteIndex, address pointer) external override onlyOwner whenPartsNotLocked {
        art.setPalettePointer(paletteIndex, pointer);
    }

    /**
     * @notice Add a batch of body images from an existing storage contract.
     * @param pointer the address of a contract where the image batch was stored using SSTORE2. The data
     * format is expected to be like {encodedCompressed}: bytes created by taking a string array of
     * RLE-encoded images, abi encoding it as a bytes array, and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches.
     * @dev This function can only be called by the owner when not locked.
     */
    function addBodiesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyOwner
        whenPartsNotLocked
    {
        art.addBodiesFromPointer(pointer, decompressedLength, imageCount);
    }

    /**
     * @notice Add a batch of accessory images from an existing storage contract.
     * @param pointer the address of a contract where the image batch was stored using SSTORE2. The data
     * format is expected to be like {encodedCompressed}: bytes created by taking a string array of
     * RLE-encoded images, abi encoding it as a bytes array, and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches.
     * @dev This function can only be called by the owner when not locked.
     */
    function addAccessoriesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyOwner
        whenPartsNotLocked
    {
        art.addAccessoriesFromPointer(pointer, decompressedLength, imageCount);
    }

    /**
     * @notice Add a batch of head images from an existing storage contract.
     * @param pointer the address of a contract where the image batch was stored using SSTORE2. The data
     * format is expected to be like {encodedCompressed}: bytes created by taking a string array of
     * RLE-encoded images, abi encoding it as a bytes array, and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches.
     * @dev This function can only be called by the owner when not locked.
     */
    function addHeadsFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyOwner
        whenPartsNotLocked
    {
        art.addHeadsFromPointer(pointer, decompressedLength, imageCount);
    }

    /**
     * @notice Add a batch of eyes images from an existing storage contract.
     * @param pointer the address of a contract where the image batch was stored using SSTORE2. The data
     * format is expected to be like {encodedCompressed}: bytes created by taking a string array of
     * RLE-encoded images, abi encoding it as a bytes array, and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches.
     * @dev This function can only be called by the owner when not locked.
     */
    function addEyesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyOwner
        whenPartsNotLocked
    {
        art.addEyesFromPointer(pointer, decompressedLength, imageCount);
    }

    /**
     * @notice Add a batch of glasses images from an existing storage contract.
     * @param pointer the address of a contract where the image batch was stored using SSTORE2. The data
     * format is expected to be like {encodedCompressed}: bytes created by taking a string array of
     * RLE-encoded images, abi encoding it as a bytes array, and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches.
     * @dev This function can only be called by the owner when not locked.
     */
    function addGlassesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyOwner
        whenPartsNotLocked
    {
        art.addGlassesFromPointer(pointer, decompressedLength, imageCount);
    }

    /**
     * @notice Get a background color by ID.
     * @param index the index of the background.
     * @return string the RGB hex value of the background.
     */
    function backgrounds(uint256 index) public view override returns (string memory) {
        return art.backgrounds(index);
    }

    /**
     * @notice Get a head image by ID.
     * @param index the index of the head.
     * @return bytes the RLE-encoded bytes of the image.
     */
    function heads(uint256 index) public view override returns (bytes memory) {
        return art.heads(index);
    }

    /**
     * @notice Get a body image by ID.
     * @param index the index of the body.
     * @return bytes the RLE-encoded bytes of the image.
     */
    function bodies(uint256 index) public view override returns (bytes memory) {
        return art.bodies(index);
    }

    /**
     * @notice Get an accessory image by ID.
     * @param index the index of the accessory.
     * @return bytes the RLE-encoded bytes of the image.
     */
    function accessories(uint256 index) public view override returns (bytes memory) {
        return art.accessories(index);
    }

    /**
     * @notice Get a eyes image by ID.
     * @param index the index of the glasses.
     * @return bytes the RLE-encoded bytes of the image.
     */
    function eyes(uint256 index) public view override returns (bytes memory) {
        return art.eyes(index);
    }

    /**
     * @notice Get a glasses image by ID.
     * @param index the index of the glasses.
     * @return bytes the RLE-encoded bytes of the image.
     */
    function glasses(uint256 index) public view override returns (bytes memory) {
        return art.glasses(index);
    }

    /**
     * @notice Get a color palette by ID.
     * @param index the index of the palette.
     * @return bytes the palette bytes, where every 3 consecutive bytes represent a color in RGB format.
     */
    function palettes(uint8 index) public view override returns (bytes memory) {
        return art.palettes(index);
    }

    /**
     * @notice Lock all parts.
     * @dev This cannot be reversed and can only be called by the owner when not locked.
     */
    function lockParts() external override onlyOwner whenPartsNotLocked {
        arePartsLocked = true;

        emit PartsLocked();
    }

    /**
     * @notice Toggle a boolean value which determines if `tokenURI` returns a data URI
     * or an HTTP URL.
     * @dev This can only be called by the owner.
     */
    function toggleDataURIEnabled() external override onlyOwner {
        bool enabled = !isDataURIEnabled;

        isDataURIEnabled = enabled;
        emit DataURIToggled(enabled);
    }

    /**
     * @notice Set the base URI for all token IDs. It is automatically
     * added as a prefix to the value returned in {tokenURI}, or to the
     * token ID if {tokenURI} is empty.
     * @dev This can only be called by the owner.
     */
    function setBaseURI(string calldata _baseURI) external override onlyOwner {
        baseURI = _baseURI;

        emit BaseURIUpdated(_baseURI);
    }

    /**
     * @notice Given a token ID and seed, construct a token URI for Plutocat
     * @dev The returned value may be a base64 encoded data URI or an API URL.
     */
    function tokenURI(uint256 tokenId, IPlutocatsSeeder.Seed memory seed)
        external
        view
        override
        returns (string memory)
    {
        if (isDataURIEnabled) {
            return dataURI(tokenId, seed);
        }
        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }

    /**
     * @notice Given a token ID and seed, construct a base64 encoded data URI for an official Plutocat.
     */
    function dataURI(uint256 tokenId, IPlutocatsSeeder.Seed memory seed) public view override returns (string memory) {
        string memory catId = tokenId.toString();
        string memory name = string(abi.encodePacked("Plutocat ", catId));
        string memory description = string(abi.encodePacked("Plutocat ", catId, " is a member of the Plutocats club"));

        return genericDataURI(name, description, seed);
    }

    /**
     * @notice Given a name, description, and seed, construct a base64 encoded data URI.
     */
    function genericDataURI(string memory name, string memory description, IPlutocatsSeeder.Seed memory seed)
        public
        view
        override
        returns (string memory)
    {
        NFTDescriptorV2.TokenURIParams memory params = NFTDescriptorV2.TokenURIParams({
            name: name,
            description: description,
            parts: getPartsForSeed(seed),
            background: art.backgrounds(seed.background)
        });
        return NFTDescriptorV2.constructTokenURI(renderer, params);
    }

    /**
     * @notice Given a seed, construct a base64 encoded SVG image.
     */
    function generateSVGImage(IPlutocatsSeeder.Seed memory seed) external view override returns (string memory) {
        ISVGRenderer.SVGParams memory params =
            ISVGRenderer.SVGParams({parts: getPartsForSeed(seed), background: art.backgrounds(seed.background)});
        return NFTDescriptorV2.generateSVGImage(renderer, params);
    }

    /**
     * @notice Get all parts for the passed `seed`.
     */
    function getPartsForSeed(IPlutocatsSeeder.Seed memory seed) public view returns (ISVGRenderer.Part[] memory) {
        bytes memory body = art.bodies(seed.body);
        bytes memory accessory = art.accessories(seed.accessory);
        bytes memory head = art.heads(seed.head);
        bytes memory eyes_ = art.eyes(seed.eyes);
        bytes memory glasses_ = art.glasses(seed.glasses);

        ISVGRenderer.Part[] memory parts = new ISVGRenderer.Part[](5);
        parts[0] = ISVGRenderer.Part({image: body, palette: _getPalette(body)});
        parts[1] = ISVGRenderer.Part({image: accessory, palette: _getPalette(accessory)});
        parts[2] = ISVGRenderer.Part({image: head, palette: _getPalette(head)});
        parts[3] = ISVGRenderer.Part({image: eyes_, palette: _getPalette(eyes_)});
        parts[4] = ISVGRenderer.Part({image: glasses_, palette: _getPalette(glasses_)});

        return parts;
    }

    /**
     * @notice Get the color palette pointer for the passed part.
     */
    function _getPalette(bytes memory part) private view returns (bytes memory) {
        return art.palettes(uint8(part[0]));
    }
}
