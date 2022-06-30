// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import { BaseOrderTest } from "../utils/BaseOrderTest.sol";
import { BasicOrderParameters } from "../../../contracts/lib/ConsiderationStructs.sol";
import { BasicOrderType } from "../../../contracts/lib/ConsiderationStructs.sol";
import { ConsiderationInterface } from "../../../contracts/interfaces/ConsiderationInterface.sol";

contract BasicOrderDive is BaseOrderTest {
    BasicOrderParameters basicOrderParameters;
    ConsiderationInterface consideration;

    struct FuzzInputsCommon {
        address zone;
        uint256 tokenId;
        uint128 paymentAmount;
        bytes32 zoneHash;
        uint256 salt;
    }

    function testBasicEthTo721() public {
        FuzzInputsCommon memory inputs = FuzzInputsCommon(
            address(0x0),
            1,
            1 ether,
            bytes32(0x0),
            0
        );

        // add erc721 to offer
        // addOfferItem(ItemType.ERC721, token, identifier, startAmount, endAmount)
        // stored in OfferItem[]
        addErc721OfferItem(inputs.tokenId);

        // add eth as consideration
        // addConsiderationItem(recipient, ItemType.NATIVE, token, identifier, startAmount, endAmount)
        // stored in ConsiderationItem[]
        addErc20ConsiderationItem(alice, inputs.paymentAmount);

        // setup OrderComponents based on configurations above
        _configureBasicOrderParametersEthTo721(inputs);

        test721_1.mint(alice, inputs.tokenId);

        // get counter for alice the offerer
        uint256 counter = consideration.getCounter(alice);

        // get order hash
        bytes32 orderHash = consideration.getOrderHash(baseOrderComponents);

        // sign baseOrderComponents with offerer pk (offer?)
        bytes memory signature = signOrder(consideration, alicePk, orderHash);

        // set signature in basicOrderParameters
        basicOrderParameters.signature = signature;

        // fulfill the order as this user
        consideration.fulfillBasicOrder{ value: inputs.paymentAmount }(
            basicOrderParameters
        );
    }

    function _configureBasicOrderParametersEthTo721(
        FuzzInputsCommon memory args
    ) internal {
        basicOrderParameters.considerationToken = address(0);
        basicOrderParameters.considerationIdentifier = 0;
        basicOrderParameters.considerationAmount = args.paymentAmount;
        basicOrderParameters.offerer = payable(alice);
        basicOrderParameters.zone = args.zone;
        basicOrderParameters.offerToken = address(test721_1);
        basicOrderParameters.offerIdentifier = args.tokenId;
        basicOrderParameters.offerAmount = 1;
        basicOrderParameters.basicOrderType = BasicOrderType
            .ETH_TO_ERC721_FULL_OPEN;
        basicOrderParameters.startTime = block.timestamp;
        basicOrderParameters.endTime = block.timestamp + 100;
        basicOrderParameters.zoneHash = args.zoneHash;
        basicOrderParameters.salt = args.salt;
        basicOrderParameters.offererConduitKey = bytes32(0);
        basicOrderParameters.fulfillerConduitKey = bytes32(0);
        basicOrderParameters.totalOriginalAdditionalRecipients = 0;
        // additional recipients should always be empty
        // don't do signature;
    }
}
