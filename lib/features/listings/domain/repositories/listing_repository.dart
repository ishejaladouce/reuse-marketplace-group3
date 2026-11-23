
import '../../data/models/listing_model.dart';

abstract class ListingRepository {
  Future<String> createListing(ListingModel listing);

  Future<ListingModel?> getListingById(String listingId);

  Stream<List<ListingModel>> watchListings();

  Stream<List<ListingModel>> watchUserListings(String sellerId);

  Future<void> updateListing(ListingModel listing);

  Future<void> deleteListing(String listingId);
}
