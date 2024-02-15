// SPDX-License-Identifier: GPL-3.0

/// @title Interface for Plutocats Seeder

pragma solidity >=0.8.0;

import {IPlutocatsSeeder} from "./IPlutocatsSeeder.sol";
import {ISVGRenderer} from "nouns-monorepo/packages/nouns-contracts/contracts/interfaces/ISVGRenderer.sol";
import {IPlutocatsArt} from "./IPlutocatsArt.sol";
import {IPlutocatsDescriptorMinimal} from "./IPlutocatsDescriptorMinimal.sol";

interface IPlutocatsDescriptor is IPlutocatsDescriptorMinimal {
    event PartsLocked();
    event DataURIToggled(bool enabled);
    event BaseURIUpdated(string baseURI);
    event ArtUpdated(IPlutocatsArt art);
    event RendererUpdated(ISVGRenderer renderer);

    error EmptyPalette();
    error BadPaletteLength();
    error IndexNotFound();

    function arePartsLocked() external returns (bool);
    function isDataURIEnabled() external returns (bool);
    function baseURI() external returns (string memory);
    function palettes(uint8 paletteIndex) external view returns (bytes memory);
    function backgrounds(uint256 index) external view returns (string memory);
    function bodies(uint256 index) external view returns (bytes memory);
    function accessories(uint256 index) external view returns (bytes memory);
    function heads(uint256 index) external view returns (bytes memory);
    function eyes(uint256 index) external view returns (bytes memory);
    function glasses(uint256 index) external view returns (bytes memory);
    function backgroundCount() external view override returns (uint256);
    function bodyCount() external view override returns (uint256);
    function accessoryCount() external view override returns (uint256);
    function headCount() external view override returns (uint256);
    function eyesCount() external view override returns (uint256);
    function glassesCount() external view override returns (uint256);
    function addManyBackgrounds(string[] calldata backgrounds) external;
    function addBackground(string calldata background) external;
    function setPalette(uint8 paletteIndex, bytes calldata palette) external;
    function addBodies(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount) external;
    function addAccessories(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount) external;
    function addHeads(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount) external;
    function addEyes(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount) external;
    function addGlasses(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount) external;
    function setPalettePointer(uint8 paletteIndex, address pointer) external;
    function addBodiesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount) external;
    function addAccessoriesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount) external;
    function addHeadsFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount) external;
    function addEyesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount) external;
    function addGlassesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount) external;
    function lockParts() external;
    function toggleDataURIEnabled() external;
    function setBaseURI(string calldata baseURI) external;
    function tokenURI(uint256 tokenId, IPlutocatsSeeder.Seed memory seed)
        external
        view
        override
        returns (string memory);
    function dataURI(uint256 tokenId, IPlutocatsSeeder.Seed memory seed)
        external
        view
        override
        returns (string memory);
    function genericDataURI(string calldata name, string calldata description, IPlutocatsSeeder.Seed memory seed)
        external
        view
        returns (string memory);
    function generateSVGImage(IPlutocatsSeeder.Seed memory seed) external view returns (string memory);
}
