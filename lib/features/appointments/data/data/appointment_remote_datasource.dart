import '../../../../core/data/firebase_remote_data_source.dart';
import '../model/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getAll();
  Future<AppointmentModel?> getById(String id);
  Future<String> add(AppointmentModel appointment);
  Future<void> update(AppointmentModel appointment);
  Future<void> delete(String id);
  Future<void> updateStatus(String id, String status);
  Stream<List<AppointmentModel>> watchUserAppointments(String userId);
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final FirebaseRemoteDS<AppointmentModel> _remote;

  AppointmentRemoteDataSourceImpl()
      : _remote = FirebaseRemoteDS<AppointmentModel>(
          collectionName: 'appointments',
          fromFirestore: (doc) => AppointmentModel.fromFirestore(doc),
          toFirestore: (m) => m.toJson(),
        );

  @override
  Future<List<AppointmentModel>> getAll() async => await _remote.getAll();

  @override
  Future<AppointmentModel?> getById(String id) async => await _remote.getById(id);

  @override
  Future<String> add(AppointmentModel appointment) async => await _remote.add(appointment);

  @override
  Future<void> update(AppointmentModel appointment) async =>
      await _remote.update(appointment.id, appointment);

  @override
  Future<void> delete(String id) async => await _remote.delete(id);

  @override
  Future<void> updateStatus(String id, String status) async {
    // Use updateFields for partial update
    await _remote.updateFields(id, {'status': status});
  }

  @override
  Stream<List<AppointmentModel>> watchUserAppointments(String userId) {
    return _remote.watchAllWhere('userId', userId);
  }
}