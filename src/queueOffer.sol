// SPDX-License-Identifier: MIT
// Inspired by OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/DoubleEndedQueue.sol)

pragma solidity ^0.8.19;

import "openzeppelin-contracts/utils/math/SafeCast.sol";

/**
 * @title Queue Offer smart contract
 * @author 0xAurelou
 * @dev A sequence of items with the ability to efficiently push and pop items (i.e. insert and remove) on both ends of
 * the sequence (called front and back).  used to implement efficient FIFO queues.
 *  Storage use is optimized, and all operations are O(1) constant time. This includes {clear}, given that
 * the existing queue contents are left in storage.
 *
 * The struct is called `OfferQueue`. Other types can be cast to and from `uint256`. This data structure can only be
 * used in storage, and not in memory.
 * ```
 * Queue.OfferQueue queue;
 * ```
 *
 * _Available since v4.6._
 */
library Queue {
    /**
     * @dev An operation (e.g. {front}) couldn't be completed due to the queue being empty.
     */
    error Empty();

    /**
     * @dev An operation (e.g. {at}) couldn't be completed due to an index being out of bounds.
     */
    error OutOfBounds();

    event OfferCreated(Offer offer);
    event OfferTaken(Offer offer);
    event OfferModified(Offer offer);

    /**
     * @dev Indices are signed integers because the queue can grow in any direction. They are 128 bits so begin and end
     * are packed in a single storage slot for efficient access. Since the items are added one at a time we can safely
     * assume that these 128-bit indices will not overflow, and use unchecked arithmetic.
     *
     * Struct members have an underscore prefix indicating that they are "private" and should not be read or written to
     * directly. Use the functions provided below instead. Modifying the struct manually may violate assumptions and
     * lead to unexpected behavior.
     *
     * Indices are in the range [begin, end) which means the first item is at data[begin] and the last item is at
     * data[end - 1].
     */
    struct OfferQueue {
        uint128 _begin;
        uint128 _end;
        mapping(uint128 => Offer) _value;
    }

    struct Offer {
        uint256 offerId;
        address token;
        uint256 amount;
        uint256 timestamp;
        address owner;
    }

    // This function will be used to check if the order is take partially or not. If yes we delete we don't delete the order just update the amount
    function takeQueueOffer(OfferQueue storage queue, uint256 amount)
        internal
        returns (Offer memory value, uint256 remaining)
    {
        if (isEmpty(queue)) revert Empty();
        uint128 index = uint128(front(queue).offerId);
        value = queue._value[index];
        remaining = 0;
        if (value.amount > amount) {
            value.amount = value.amount - amount;
            queue._value[index] = value;
            emit OfferModified(value);
        } else {
            delete queue._value[index];
            unchecked {
                queue._begin = index + 1;
            }
            emit OfferTaken(value);
            remaining = amount - value.amount;
        }
    }

    /**
     * @dev Inserts an item at the end of the queue.
     */
    function createQueueOffer(OfferQueue storage queue, Offer memory offer) internal {
        uint128 backIndex = queue._end;
        queue._value[backIndex] = offer;
        unchecked {
            queue._end = backIndex + 1;
        }
        emit OfferCreated(offer);
    }

    /**
     * @dev Returns the item at the beginning of the queue.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function front(OfferQueue storage queue) internal view returns (Offer memory value) {
        if (isEmpty(queue)) revert Empty();
        uint128 frontIndex = queue._begin;
        return queue._value[frontIndex];
    }

    /**
     * @dev Returns the item at the end of the queue.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function back(OfferQueue storage queue) internal view returns (Offer memory value) {
        if (isEmpty(queue)) revert Empty();
        uint128 backIndex;
        unchecked {
            backIndex = queue._end - 1;
        }
        return queue._value[backIndex];
    }

    /**
     * @dev Return the item at a position in the queue given by `index`, with the first item at 0 and last item at
     * `length(queue) - 1`.
     *
     * Reverts with `OutOfBounds` if the index is out of bounds.
     */
    function at(OfferQueue storage queue, uint256 index) internal view returns (Offer memory value) {
        // int256(queue._begin) is a safe upcast
        uint128 idx = SafeCast.toUint128(uint256(queue._begin) + index);
        if (idx >= queue._end) revert OutOfBounds();
        return queue._value[idx];
    }

    /**
     * @dev Resets the queue back to being empty.
     *
     * NOTE: The current items are left behind in storage. This does not affect the functioning of the queue, but misses
     * out on potential gas refunds.
     */
    function clear(OfferQueue storage queue) internal {
        queue._begin = 0;
        queue._end = 0;
    }

    /**
     * @dev Returns the number of items in the queue.
     */
    function length(OfferQueue storage queue) public view returns (uint256) {
        // The interface preserves the invariant that begin <= end so we assume this will not overflow.
        // We also assume there are at most int256.max items in the queue.
        unchecked {
            return uint256(queue._end - queue._begin);
        }
    }

    /**
     * @dev Returns true if the queue is empty.
     */
    function isEmpty(OfferQueue storage queue) public view returns (bool) {
        return queue._end <= queue._begin;
    }

    /**
     * @notice  get all the offer in the queue
     * @dev     .
     * @param   queue  the queue to get the offers from.
     * @return  Offer[]  the list of offers in the queue.
     */
    function getQueue(OfferQueue storage queue) public view returns (Offer[] memory) {
        uint256 len = length(queue);
        Offer[] memory offers = new Offer[](len);
        for (uint256 i = 0; i < len;) {
            offers[i] = at(queue, i);
            unchecked {
                i++;
            }
        }
        return offers;
    }
}
