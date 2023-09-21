# How to keep track of NFT ownerships with low costs.

## The ERC721Enumerble way

   #### Trade offs

   #### When should it be used or not

## Using events

OpenSea uses a few different methods to quickly determine which NFTs an address owns, even if most NFTs don't use ERC721 enumerable.

**Event listeners**: OpenSea listens for events on the blockchain that indicate that an NFT has been transferred to an address. When it sees one of these events, it updates its database to reflect the new ownership.

**Indexers**: OpenSea uses indexers to scan the blockchain for all NFT transfers. This allows them to build a database of all NFT ownership, even for NFTs that don't use ERC721 enumerable.

**APIs**: OpenSea also uses APIs from other NFT marketplaces and aggregators to get information about NFT ownership. This helps them to fill in any gaps in their own database.
If I were creating an NFT marketplace, I would use a similar approach to OpenSea. I would use event listeners to track NFT transfers, and I would use indexers and APIs to get information about NFT ownership. I would also build a database of all NFT ownership, so that I could quickly and easily look up the NFTs owned by any address.

In addition to these methods, I would also consider using the following techniques to improve the efficiency of NFT ownership lookups:

**Bloom filters**: Bloom filters are a probabilistic data structure that can be used to quickly check if an element is a member of a set. This could be used to improve the performance of event listeners, by only checking the bloom filter for events that are likely to be relevant.

**Caches**: Caches can be used to store recently-accessed data in memory. This can improve the performance of NFT ownership lookups, by reducing the number of times that the database needs to be accessed.

**Sharding**: Sharding is a technique that divides a database into smaller partitions, called shards. This can improve the performance of NFT ownership lookups, by spreading the load across multiple shards.
By using these techniques, it is possible to create an NFT marketplace that can quickly and efficiently determine which NFTs an address owns, even if most NFTs don't use ERC721 enumerable.