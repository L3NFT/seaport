// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import { BaseOrderTest } from "../utils/BaseOrderTest.sol";
import { BasicOrderParameters } from "../../../contracts/lib/ConsiderationStructs.sol";
import { OrderType, BasicOrderType } from "../../../contracts/lib/ConsiderationEnums.sol";
import { ConsiderationInterface } from "../../../contracts/interfaces/ConsiderationInterface.sol";
import { Consideration } from "../../../contracts/lib/Consideration.sol";

contract BasicOrderDive is BaseOrderTest {
    BasicOrderParameters basicOrderParameters;

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
        addEthConsiderationItem(alice, inputs.paymentAmount);

        // setup OrderParameters based on configurations above specific to this example exchange
        _configureBasicOrderParametersEthTo721(inputs);

        test721_1.mint(alice, inputs.tokenId);

        // setup OrderComponents
        _configureOrderComponents(
            inputs.zone,
            inputs.zoneHash,
            inputs.salt,
            bytes32(0)
        );

        // pull consideration contract from BaseConsiderationTest which deploys code from precompiled source
        // get counter for alice the offerer
        uint256 counter = consideration.getCounter(alice);
        baseOrderComponents.counter = counter;

        // get order hash
        bytes32 orderHash = consideration.getOrderHash(baseOrderComponents);

        // sign baseOrderComponents with offerer pk (offer?)
        bytes memory signature = signOrder(consideration, alicePk, orderHash);

        // set signature in basicOrderParameters
        basicOrderParameters.signature = signature;

        // fulfill the order as this user
        // verifies that the order parameters match signature for order components
        consideration.fulfillBasicOrder{ value: inputs.paymentAmount }(
            basicOrderParameters
        );
    }

    function _configureOrderComponents(
        address zone,
        bytes32 zoneHash,
        uint256 salt,
        bytes32 conduitKey
    ) internal {
        baseOrderComponents.offerer = alice;
        baseOrderComponents.zone = zone;
        baseOrderComponents.offer = offerItems;
        baseOrderComponents.consideration = considerationItems;
        baseOrderComponents.orderType = OrderType.FULL_OPEN;
        baseOrderComponents.startTime = block.timestamp;
        baseOrderComponents.endTime = block.timestamp + 100;
        baseOrderComponents.zoneHash = zoneHash;
        baseOrderComponents.salt = salt;
        baseOrderComponents.conduitKey = conduitKey;
        // don't set counter
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
