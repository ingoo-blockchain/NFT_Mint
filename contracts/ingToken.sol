// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./node_modules/openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./node_modules/openzeppelin-solidity/contracts/utils/Strings.sol";
import "./node_modules/openzeppelin-solidity/contracts/access/Ownable.sol";

contract IngToken is ERC721Enumerable, Ownable{

    uint constant public MAX_TOKEN_COUNT = 1000;
    uint constant public TOKEN_RANK = 4;
    uint constant public TOKEN_TYPE = 4;

    string public metadataURI;
    uint public mintingPrice = 1 ether;
    constructor(string memory _name, string memory _symbol, string memory _metadataURI) ERC721(_name, _symbol){
        metadataURI = _metadataURI;
    }

    struct TokenData {
        uint Rank;
        uint Type;
    }

    mapping(uint => TokenData) public TokenDatas;
    uint[TOKEN_RANK][TOKEN_TYPE] public TokenCount;

    function mintToken() public payable {

        require(msg.value == mintingPrice,"Not enough Ether");
        require(MAX_TOKEN_COUNT > totalSupply(), "No more mintiong is possible.");

        uint tokenId = totalSupply() + 1; 

        TokenData memory random = getRandomNum(msg.sender, tokenId);
        TokenDatas[tokenId] = TokenData(random.Rank, random.Type);
        TokenCount[random.Rank-1][random.Type-1];

        TokenDatas[tokenId] = TokenData(1,1);
        payable(owner()).transfer(msg.value);
        _mint(msg.sender, tokenId);
    }

    function tokenURI(uint _tokenId) public view override returns (string memory) {
        string memory Rank = Strings.toString(TokenDatas[_tokenId].Rank);
        string memory Type = Strings.toString(TokenDatas[_tokenId].Type);
        return string(abi.encodePacked(metadataURI,'/',Rank,'/',Type,'.json'));
    }

    function getTokenCount() public view returns(uint[TOKEN_RANK][TOKEN_TYPE] memory) {
        return TokenCount;
    }

    function getTokenRank(uint _tokenId) public view returns(uint) {
        return TokenDatas[_tokenId].Rank;
    }

    function getTokenType(uint _tokenId) public view returns(uint) {
        return TokenDatas[_tokenId].Type;
    }

    function getRandomNum(address _msgSender, uint _tokenId) private pure returns(TokenData memory) {
        uint randomNum = uint(keccak256(abi.encodePacked(_msgSender, _tokenId))) % 100;
        TokenData memory data;

       if (randomNum < 5) {
            if (randomNum == 1) {
                data.Rank = 4;
                data.Type = 1;
            } else if (randomNum == 2) {
                data.Rank = 4;
                data.Type = 2;
            } else if (randomNum == 3) {
                data.Rank = 4;
                data.Type = 3;
            } else {
                data.Rank = 4;
                data.Type = 4;
            }
        } else if (randomNum < 13) {
            if (randomNum < 7) {
                data.Rank = 3;
                data.Type = 1;
            } else if (randomNum < 9) {
                data.Rank = 3;
                data.Type = 2;
            } else if (randomNum < 11) {
                data.Rank = 3;
                data.Type = 3;
            } else {
                data.Rank = 3;
                data.Type = 4;
            }
        } else if (randomNum < 37) {
            if (randomNum < 19) {
                data.Rank = 2;
                data.Type = 1;
            } else if (randomNum < 25) {
                data.Rank = 2;
                data.Type = 2;
            } else if (randomNum < 31) {
                data.Rank = 2;
                data.Type = 3;
            } else {
                data.Rank = 2;
                data.Type = 4;
            }
        } else {
            if (randomNum < 52) {
                data.Rank = 1;
                data.Type = 1;
            } else if (randomNum < 68) {
                data.Rank = 1;
                data.Type = 2;
            } else if (randomNum < 84) {
                data.Rank = 1;
                data.Type = 3;
            } else {
                data.Rank = 1;
                data.Type = 4;
            }
        }

        return data;
    }

    function setMetadataURI(string memory _uri) public onlyOwner {
        metadataURI = _uri;
    }   
}