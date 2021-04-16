//SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IAavegotchi.sol";
import "./ERC721Holder.sol";

import "hardhat/console.sol";

contract Protocol is ERC721Holder {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IAavegotchi game;
    IERC721 gotchis;
    IERC20 ghst;

    struct Gotchi {
        uint256 pricePerShare;
        uint256 availableShares;
        uint256 totalShares;
        address owner;
        bool dissolved;
        mapping(address => uint256) shares;
    }

    mapping(uint256 => Gotchi) communityGotchis;

    constructor(
        IAavegotchi _game,
        IERC721 _gotchis,
        IERC20 _ghst
    ) {
        game = _game;
        gotchis = _gotchis;
        ghst = _ghst;
    }

    modifier onlyGotchiOwner(uint256 gotchiId) {
        require(msg.sender == communityGotchis[gotchiId].owner);
        _;
    }

    function startCommunityGotchi(
        uint256 gotchiId,
        uint256 pricePerShare,
        uint256 totalShares
    ) external {
        require(communityGotchis[gotchiId].owner == address(0), "EXISTS");

        gotchis.safeTransferFrom(msg.sender, address(this), gotchiId);

        Gotchi storage _gotchi = communityGotchis[gotchiId];
        _gotchi.pricePerShare = pricePerShare;
        _gotchi.availableShares = totalShares;
        _gotchi.totalShares = totalShares;
        _gotchi.owner = msg.sender;
    }

    function joinCommunity(uint256 gotchiId, uint256 sharesToBuy) external {
        Gotchi storage _gotchi = communityGotchis[gotchiId];

        require(_gotchi.availableShares > sharesToBuy, "!SHARES");
        require(!_gotchi.dissolved, "DISSOLVED");

        ghst.safeTransferFrom(
            msg.sender,
            address(this),
            _gotchi.availableShares.mul(_gotchi.pricePerShare)
        );

        _gotchi.availableShares = _gotchi.availableShares.sub(sharesToBuy);
        _gotchi.shares[msg.sender] = _gotchi.shares[msg.sender].add(
            sharesToBuy
        );
    }

    function disolveCommunity(uint256 gotchiId)
        external
        onlyGotchiOwner(gotchiId)
    {
        communityGotchis[gotchiId].dissolved = true;
    }

    function claimShares(uint256 gotchiId) external {
        Gotchi storage _gotchi = communityGotchis[gotchiId];
        require(_gotchi.dissolved, "!DISSOLVED");

        uint256 shares = _gotchi.shares[msg.sender];

        ghst.safeTransfer(msg.sender, shares);
    }
}
