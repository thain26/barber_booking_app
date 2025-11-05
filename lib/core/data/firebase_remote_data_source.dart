import 'package:cloud_firestore/cloud_firestore.dart';

/// A generic Firestore DataSource for basic CRUD operations.
/// T = Model type that represents the Firestore document.
class FirebaseRemoteDS<T> {
  final String collectionName;
  final T Function(DocumentSnapshot doc) fromFirestore;
  final Map<String, dynamic> Function(T item) toFirestore;

  FirebaseRemoteDS({
    required this.collectionName,
    required this.fromFirestore,
    required this.toFirestore,
  });

  CollectionReference get _collection =>
      FirebaseFirestore.instance.collection(collectionName);

  /// Get all documents in the collection
  Future<List<T>> getAll() async {
    final snapshot =
        await _collection.orderBy('created_at', descending: true).get();
    return snapshot.docs.map((e) => fromFirestore(e)).toList();
  }
  
  Future<List<T>> getAllWhere(String field, dynamic value) async {
    final snapshot = await _collection
        .where(field, isEqualTo: value)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((e) => fromFirestore(e)).toList();
  }

  /// Watch documents filtered by a field value
  Stream<List<T>> watchAllWhere(String field, dynamic value) {
    // Remove orderBy to avoid composite index requirement
    return _collection
        .where(field, isEqualTo: value)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => fromFirestore(d))
            .toList()
          ..sort((a, b) {
            // Cast to dynamic to access date field
            final aDate = (a as dynamic).date;
            final bDate = (b as dynamic).date;
            return bDate.compareTo(aDate); // Sort descending
          }));
  }

  /// Get a single document by ID
  Future<T?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return fromFirestore(doc);
  }

  /// Add a new document, returns generated id
  Future<String> add(T item) async {
    final data = toFirestore(item);
    final docRef = await _collection.add(data);
    return docRef.id;
  }

  /// Update (or create) an existing document with given id
  Future<void> update(String id, T item) async {
    final data = toFirestore(item);
    await _collection.doc(id).set(data, SetOptions(merge: false));
  }

  Future<void> updateFields(String id, Map<String, dynamic> fields) async {
      await _collection.doc(id).update(fields);
  }

  /// Delete a document
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  /// Listen to realtime changes in a collection
  Stream<List<T>> watchAll() {
    return _collection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => fromFirestore(d)).toList());
  }

  /// Listen to realtime changes for a single document
  Stream<T?> watchById(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return fromFirestore(doc);
    });
  }
}
