import '../../data/data/appointment_remote_datasource.dart';
import '../../data/model/appointment_model.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repositories.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;
  AppointmentRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createAppointment(Appointment appointment) async {
    final model = AppointmentModel.fromEntity(appointment);
    // remote.add returns created doc id
    final id = await remoteDataSource.add(model);
    // optionally return or use id
  }

  @override
  Future<void> deleteAppointment(String id) async {
    await remoteDataSource.delete(id);
  }

  @override
  Future<void> updateStatus(String id, String status) async {
    // If status is "cancelled" remove the document instead of updating the status
    if (status.toLowerCase() == 'cancelled') {
      await remoteDataSource.delete(id);
    } else {
      await remoteDataSource.updateStatus(id, status);
    }
  }

  @override
  Future<List<Appointment>> getAppointments() async {
    final models = await remoteDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Appointment?> getAppointment(String id) async {
    final m = await remoteDataSource.getById(id);
    return m?.toEntity();
  }

  @override
  Stream<List<Appointment>> watchUserAppointments(String userId) {
    return remoteDataSource.watchUserAppointments(userId).map((list) => list.map((m) => m.toEntity()).toList());
  }
}