import 'package:baberbookingapp/features/appointments/domain/repositories/appointment_repositories.dart';

import '../entities/appointment.dart';

class AddAppointment {
  final AppointmentRepository repository;
  AddAppointment(this.repository);

  Future<void> call(Appointment appointment) async {
    await repository.createAppointment(appointment);
  }
}