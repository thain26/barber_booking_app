import '../repositories/appointment_repositories.dart';

class DeleteAppointment {
  final AppointmentRepository repository;
  DeleteAppointment(this.repository);

  Future<void> call(String id) async {
    await repository.deleteAppointment(id);
  }
}