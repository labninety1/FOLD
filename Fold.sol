// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import "./EnefteOwnership.sol";
import "./ITwenty6Fifty2.sol";
import "./INinety1.sol";
import "./IFoldStaking.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
* @title $Fold
* @author lileddie.eth / Enefte Studio
*/
contract Fold is ERC20, EnefteOwnership {

    INinety1 NINETY_ONE; 
    ITwenty6Fifty2 TWENTY; 
    IFoldStaking foldStaking;
    uint256 private constant MAX_SUPPLY = 2652000000 ether;
    uint256 private constant FOLD_TOKEN_PRECISION = 1e18;
    
    modifier onlyTwenty() {
        if(msg.sender != address(TWENTY)){
            revert("Only twenty contract allowed.");
        }
        _;
    }

    /**
    * @notice mint the $Fold to the TWENTY contract upon NFT creation
    *
    * @param _amount amount to mint
    */
    function mint(uint _amount) external onlyTwenty {
        if(_amount + totalSupply() > MAX_SUPPLY){
            revert("Tokens all allocated");
        }
        _mint(address(TWENTY), _amount);
    }

    /**
    * @notice mint the $Fold to the TWENTY contract upon NFT creation
    *
    * @param _amount amount to mint
    */
    function mintStakingShare(uint _amount) external onlyOwner {
        uint256 realAmount = _amount*FOLD_TOKEN_PRECISION;
        if(realAmount + totalSupply() > MAX_SUPPLY){
            revert("Tokens all allocated");
        }
        _mint(address(foldStaking), realAmount);
    }

    

    /**
    * @notice set the address for the 91 smart contract
    *
    */
    function setContracts(address _address2652, address _address91, address _addressStaking) external onlyOwner {
        TWENTY = ITwenty6Fifty2(_address2652);
        NINETY_ONE = INinety1(_address91);
        foldStaking = IFoldStaking(_addressStaking);
    }

     function _afterTokenTransfer(
        address from,
        address to,
        uint256 _amount
    ) internal virtual override {
        uint256 amount = _amount/FOLD_TOKEN_PRECISION;
        if(to == address(TWENTY)){
            // do nothing, tokens inside to 2652 NFT
        }
        else if(to == address(NINETY_ONE)){
            // do nothing, tokens inside to 91 NFT
        }
        else if(to == address(foldStaking)){
            // do nothing, tokens minted to staking contract dont earn
        }
        else if(from == address(foldStaking)){
            // claiming from the staking contract
        }
        else if(foldStaking.isValidLP(to)){
            // Sent FLD to an LP
            foldStaking.withdraw(amount,from);
        }
        else if(foldStaking.isValidLP(from)){
            // Withdrew FLD from an LP
            foldStaking.deposit(amount,to);
        }
        else if(from == address(0)){
            //mint
            foldStaking.deposit(amount,to);
        }   
        else if(to == address(0)){
            //burn
            foldStaking.withdraw(amount,from);
        }  
        else if(from == address(NINETY_ONE)){
            // Cashing out a 91 NFT
            foldStaking.deposit(amount,to);
        }
        else { // wallet -> wallet transfer
            foldStaking.withdraw(amount,from);
            foldStaking.deposit(amount,to);
        }  
    }



    constructor() ERC20("Fold", "FLD") {
        setOwner(msg.sender);
    }

}