// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./ingToken.sol";

contract SaleToken {
    IngToken public Token;

    constructor(address _tokenAddress) {
        Token = IngToken(_tokenAddress);
    }

    struct TokenInfo {
        uint tokenId;
        uint Rank;
        uint Type;
        uint price;
    }

    mapping(uint => uint) public tokenPrices; // 토큰 가격 맵핑
    uint[] public SaleTokenList; // 판매 토큰 리스트

    // 판매
    function SalesToken(uint _tokenId, uint _price) public {
        address tokenOwner = Token.ownerOf(_tokenId);

        require(tokenOwner == msg.sender, "Caller is not Token Owner.");
        require(_price > 0, "Price is zero or lower.");
        require(tokenPrices[_tokenId] == 0, "This Token is already on sale.");
        require(Token.isApprovedForAll(msg.sender, address(this)));

        SaleTokenList.push(_tokenId);
    }

    //구매
    function PurchaseToken(uint _tokenId) public payable {
        address tokenOwner = Token.ownerOf(_tokenId);

        require(tokenOwner != msg.sender, "Caller is Token Owner.");
        require(tokenPrices[_tokenId] > 0, "this token not sale.");
        require(tokenPrices[_tokenId] <= msg.value, "Caller sent lower than price");

        payable(tokenOwner).transfer(msg.value);
        Token.safeTransferFrom(tokenOwner, msg.sender, _tokenId);
        tokenPrices[_tokenId] = 0;

        popSaleToken(_tokenId);
    }

    function popSaleToken(uint _tokenId) private returns(bool){
        for(uint i=0; i < SaleTokenList.length; i++) {
            if (SaleTokenList[i] == _tokenId) {
                SaleTokenList[i] = SaleTokenList[SaleTokenList.length - 1];
                SaleTokenList.pop();
                return true;
            }
        }
        return false;
    }

    function getSaleTokenList() public view returns (TokenInfo[] memory){
        require(SaleTokenList.length > 0 , "Not exist on sale Token");

        TokenInfo[] memory list = new TokenInfo[](SaleTokenList.length);

        for(uint i = 0; i < SaleTokenList.length; i++) {
            uint tokenId = SaleTokenList[i];
            (uint Rank, uint Type, uint Price) = getTokenInfo(tokenId);
            list[i] = TokenInfo(tokenId, Rank, Type, Price);
        }

        return list;
    }

    function getOwnerTokens(address _tokenOwner) public view returns(TokenInfo[] memory) {
        uint balance = Token.balanceOf(_tokenOwner);

        require(balance != 0, "Token owner did not have token.");
        TokenInfo[] memory list = new TokenInfo[](balance);

        for(uint i =0; i< balance; i++) {
            uint tokenId = Token.tokenOfOwnerByIndex(_tokenOwner, i);
            (uint Rank, uint Type, uint Price) = getTokenInfo(tokenId);
            list[i] = TokenInfo(tokenId, Rank, Type, Price);
        }

        return list;
    }

    function getLatestToken(address _tokenOwner) public view returns(TokenInfo memory) {
        uint balance = Token.balanceOf(_tokenOwner);
        uint tokenId = Token.tokenOfOwnerByIndex(_tokenOwner, balance -1);
        (uint Rank, uint Type, uint Price) = getTokenInfo(tokenId);
        return TokenInfo(tokenId, Rank, Type, Price);
    }

    function getTokenInfo(uint _tokenId) public view returns (uint, uint, uint){
        uint Rank = Token.getTokenRank(_tokenId);
        uint Type = Token.getTokenType(_tokenId);
        uint Price = tokenPrices[_tokenId];

        return (Rank, Type, Price);
    }

}