import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/data/appointment_remote_datasource.dart';
import '../../data/repositories/appointment_repositories_impl.dart';
import '../../domain/entities/appointment.dart';
import 'package:go_router/go_router.dart';

class AppointmentFormPage extends StatefulWidget {
  final Map<String, dynamic>? serviceDetails;
  const AppointmentFormPage({super.key, this.serviceDetails});

  @override
  State<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  late final TextEditingController _serviceCtrl;
  late final TextEditingController _priceCtrl;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  final _remote = AppointmentRemoteDataSourceImpl();
  late final AppointmentRepositoryImpl _repo;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = AppointmentRepositoryImpl(_remote);
    _serviceCtrl = TextEditingController(text: widget.serviceDetails?['serviceName'] ?? 'Hair Cut');
    _priceCtrl = TextEditingController(text: (widget.serviceDetails?['price'] ?? 30).toString());
  }

  @override
  void dispose() {
    _serviceCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _selectedTime);
    if (t != null) setState(() => _selectedTime = t);
  }

  DateTime _combineDateTime() {
    return DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = 'Please login');
      return;
    }
    setState(() { _error = null; _isLoading = true; });

    final appointment = Appointment(
      id: '', // remote will generate id
      userId: user.uid,
      service: _serviceCtrl.text.trim(),
      date: _combineDateTime(),
      price: int.tryParse(_priceCtrl.text) ?? 0,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    try {
      await _repo.createAppointment(appointment);
      if (!mounted) return;
      context.pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat.yMMMd().format(_selectedDate);
    final timeLabel = _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment'), titleTextStyle:const TextStyle(color: Color(0xFFF3E8E2), fontSize: 20), backgroundColor: const Color(0xFF233826)),
      backgroundColor: const Color(0xFFF3E8E2),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _serviceCtrl, readOnly: widget.serviceDetails != null, decoration: const InputDecoration(labelText: 'Service', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: _priceCtrl, readOnly: widget.serviceDetails != null, decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder(), prefixText: '\$ '), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ElevatedButton(onPressed: _pickDate, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF233826)), child: Text('Date: $dateLabel', style: const TextStyle(color: Colors.white)))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: _pickTime, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF233826)), child: Text('Time: $timeLabel', style: const TextStyle(color: Colors.white)))),
            ]),
            if (_error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _isLoading ? null : _save, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF233826)), child: _isLoading ? const SizedBox(height:18,width:18,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2)) : const Text('BOOK NOW', style: const TextStyle(color: Colors.white))),
            )
          ],
        ),
      ),
    );
  }
}