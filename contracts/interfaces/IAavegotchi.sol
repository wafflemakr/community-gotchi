// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

abstract contract Events {
    event ClaimAavegotchi(uint256 indexed _tokenId);

    event SetAavegotchiName(
        uint256 indexed _tokenId,
        string _oldName,
        string _newName
    );

    event SetBatchId(uint256 indexed _batchId, uint256[] tokenIds);

    event SpendSkillpoints(uint256 indexed _tokenId, int16[4] _values);

    event LockAavegotchi(uint256 indexed _tokenId, uint256 _time);

    event UnLockAavegotchi(uint256 indexed _tokenId, uint256 _time);

    event ERC721ListingAdd(
        uint256 indexed listingId,
        address indexed seller,
        address erc721TokenAddress,
        uint256 erc721TokenId,
        uint256 indexed category,
        uint256 time
    );

    event ERC1155ListingAdd(
        uint256 indexed listingId,
        address indexed seller,
        address erc1155TokenAddress,
        uint256 erc1155TypeId,
        uint256 indexed category,
        uint256 quantity,
        uint256 priceInWei,
        uint256 time
    );

    event ERC1155ExecutedListing(
        uint256 indexed listingId,
        address indexed seller,
        address buyer,
        address erc1155TokenAddress,
        uint256 erc1155TypeId,
        uint256 indexed category,
        uint256 _quantity,
        uint256 priceInWei,
        uint256 time
    );

    event ERC1155ListingCancelled(uint256 indexed listingId);

    event ChangedListingFee(uint256 listingFeeInWei);

    event PurchaseItemsWithGhst(
        address indexed _buyer,
        address indexed _to,
        uint256[] _itemIds,
        uint256[] _quantities,
        uint256 _totalPrice
    );
}

abstract contract IAavegotchi is Events {
    uint256 constant NUMERIC_TRAITS_NUM = 6;
    uint256 constant EQUIPPED_WEARABLE_SLOTS = 16;

    struct Dimensions {
        uint8 x;
        uint8 y;
        uint8 width;
        uint8 height;
    }

    struct ItemType {
        string name; //The name of the item
        string description;
        string author;
        // treated as int8s array
        // [Experience, Rarity Score, Kinship, Eye Color, Eye Shape, Brain Size, Spookiness, Aggressiveness, Energy]
        int8[NUMERIC_TRAITS_NUM] traitModifiers; //[WEARABLE ONLY] How much the wearable modifies each trait. Should not be more than +-5 total
        //[WEARABLE ONLY] The slots that this wearable can be added to.
        bool[EQUIPPED_WEARABLE_SLOTS] slotPositions;
        // this is an array of uint indexes into the collateralTypes array
        uint8[] allowedCollaterals; //[WEARABLE ONLY] The collaterals this wearable can be equipped to. An empty array is "any"
        // SVG x,y,width,height
        Dimensions dimensions;
        uint256 ghstPrice; //How much GHST this item costs
        uint256 maxQuantity; //Total number that can be minted of this item.
        uint256 totalQuantity; //The total quantity of this item minted so far
        uint32 svgId; //The svgId of the item
        uint8 rarityScoreModifier; //Number from 1-50.
        // Each bit is a slot position. 1 is true, 0 is false
        bool canPurchaseWithGhst;
        uint16 minLevel; //The minimum Aavegotchi level required to use this item. Default is 1.
        bool canBeTransferred;
        uint8 category; // 0 is wearable, 1 is badge, 2 is consumable
        int16 kinshipBonus; //[CONSUMABLE ONLY] How much this consumable boosts (or reduces) kinship score
        uint32 experienceBonus; //[CONSUMABLE ONLY]
    }

    struct ItemTypeIO {
        uint256 balance;
        uint256 itemId;
        ItemType itemType;
    }

    struct AavegotchiInfo {
        uint256 tokenId;
        string name;
        address owner;
        uint256 randomNumber;
        uint256 status;
        int16[NUMERIC_TRAITS_NUM] numericTraits;
        int16[NUMERIC_TRAITS_NUM] modifiedNumericTraits;
        uint16[EQUIPPED_WEARABLE_SLOTS] equippedWearables;
        address collateral;
        address escrow;
        uint256 stakedAmount;
        uint256 minimumStake;
        uint256 kinship; //The kinship value of this Aavegotchi. Default is 50.
        uint256 lastInteracted;
        uint256 experience; //How much XP this Aavegotchi has accrued. Begins at 0.
        uint256 toNextLevel;
        uint256 usedSkillPoints; //number of skill points used
        uint256 level; //the current aavegotchi level
        uint256 hauntId;
        uint256 baseRarityScore;
        uint256 modifiedRarityScore;
        bool locked;
        ItemTypeIO[] items;
    }

    struct ERC1155Listing {
        uint256 listingId;
        address seller;
        address erc1155TokenAddress;
        uint256 erc1155TypeId;
        uint256 category; // 0 is wearable, 1 is badge, 2 is consumable, 3 is tickets
        uint256 quantity;
        uint256 priceInWei;
        uint256 timeCreated;
        uint256 timeLastPurchased;
        uint256 sourceListingId;
        bool sold;
        bool cancelled;
    }

    function setApprovalForAll(address _operator, bool _approved)
        external
        virtual;

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        virtual
        returns (bool approved_);

    function kinship(uint256 _tokenId)
        external
        view
        virtual
        returns (uint256 score_);

    function aavegotchiLevel(uint256 _experience)
        external
        pure
        virtual
        returns (uint256 level_);

    function interact(uint256[] calldata _tokenIds) external virtual;

    function getAavegotchi(uint256 _tokenId)
        external
        view
        virtual
        returns (AavegotchiInfo memory aavegotchiInfo_);

    function allAavegotchisOfOwner(address _owner)
        external
        view
        virtual
        returns (AavegotchiInfo[] memory aavegotchiInfos_);

    function tokenIdsOfOwner(address _owner)
        external
        view
        virtual
        returns (uint32[] memory tokenIds_);

    function getERC1155Listings(
        uint256 _category, // // 0 is wearable, 1 is badge, 2 is consumable, 3 is tickets
        string memory _sort, // "listed" or "purchased"
        uint256 _length // how many items to get back or the rest available
    ) external view virtual returns (ERC1155Listing[] memory listings_);

    function getItemType(uint256 _itemId)
        external
        view
        virtual
        returns (ItemType memory itemType_);

    function uri(uint256 _id) external view virtual returns (string memory);

    function executeERC1155Listing(
        uint256 _listingId,
        uint256 _quantity,
        uint256 _priceInWei
    ) external virtual;

    function purchaseItemsWithGhst(
        address _to,
        uint256[] calldata _itemIds,
        uint256[] calldata _quantities
    ) external virtual;
}
