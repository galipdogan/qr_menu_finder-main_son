import 'package:cloud_firestore/cloud_firestore.dart';

class MenuFirestoreQueries {
  final FirebaseFirestore firestore;

  MenuFirestoreQueries(this.firestore);

  Query baseItemsQuery() {
    return firestore.collection('items').where('status', isEqualTo: 'approved');
  }

  Query itemsByRestaurant(String restaurantId, int limit) {
    return baseItemsQuery()
        .where('restaurantId', isEqualTo: restaurantId)
        .limit(limit);
  }

  Query itemsByCategory(String category, int limit) {
    return baseItemsQuery().where('category', isEqualTo: category).limit(limit);
  }

  Query itemsByContributor(String contributorId, int limit) {
    return baseItemsQuery()
        .where('contributedBy', isEqualTo: contributorId)
        .orderBy('createdAt', descending: true)
        .limit(limit);
  }
}
