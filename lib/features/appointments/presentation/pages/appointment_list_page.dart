import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../data/data/appointment_remote_datasource.dart';
import '../../data/repositories/appointment_repositories_impl.dart';
import '../../domain/entities/appointment.dart';
import '../../../../core/routing/app_routes.dart';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  final _remote = AppointmentRemoteDataSourceImpl();
  late final AppointmentRepositoryImpl _repo;
  final _dateFmt = DateFormat('EEE, MMM d');
  final _timeFmt = DateFormat('h:mm a');

  @override
  void initState() {
    super.initState();
    _repo = AppointmentRepositoryImpl(_remote);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3E8E2),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please login to view appointments'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF233826),
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3E8E2),
      appBar: AppBar(
        title: const Text('MY APPOINTMENTS'),
        titleTextStyle: const TextStyle(
          color: Color(0xFFF3E8E2),
          fontSize: 20,
        ),
        backgroundColor: const Color(0xFF233826),
        
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: _repo.watchUserAppointments(user.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF233826),
              ),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Error: ${snap.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No bookings yet',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final a = items[i];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF233826),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.content_cut,
                      color: Color(0xFFF3E8E2),
                    ),
                  ),
                  title: Text(
                    a.service,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${_dateFmt.format(a.date)} • ${_timeFmt.format(a.date)}',
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${a.price}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF233826),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.status.toUpperCase(),
                        style: TextStyle(
                          color: a.status == 'cancelled' ? Colors.red : Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              a.service,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_dateFmt.format(a.date)} • ${_timeFmt.format(a.date)}',
                            ),
                            const SizedBox(height: 12),
                            if (a.status != 'cancelled')
                              ElevatedButton(
                                onPressed: () {
                                  _repo.updateStatus(a.id, 'cancelled');
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Cancel'),
                              ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}