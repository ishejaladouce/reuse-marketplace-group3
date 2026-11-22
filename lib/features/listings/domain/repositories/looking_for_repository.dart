
import '../../data/models/looking_for_request_model.dart';

abstract class LookingForRepository {
  Future<String> createRequest(LookingForRequestModel request);

  Future<LookingForRequestModel?> getRequestById(String requestId);

  Stream<List<LookingForRequestModel>> watchRequests();

  Stream<List<LookingForRequestModel>> watchUserRequests(
    String authorId,
  );

  Future<void> updateRequest(LookingForRequestModel request);

  Future<void> deleteRequest(String requestId);
}
