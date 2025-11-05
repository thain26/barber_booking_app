import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<void> createAppointment(Appointment appointment);
  Future<void> deleteAppointment(String id);
  Future<void> updateStatus(String id, String status);
  Future<List<Appointment>> getAppointments();
  Future<Appointment?> getAppointment(String id);
  Stream<List<Appointment>> watchUserAppointments(String userId);
}