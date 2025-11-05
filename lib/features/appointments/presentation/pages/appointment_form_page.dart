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

  final _remote = AppointmentRemoteDataSourceImpl();
  late final AppointmentRepositoryImpl _repo;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  String? _error;

  // sample time slots
  final List<TimeOfDay> _timeSlots = [
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 17, minute: 0),
    TimeOfDay(hour: 18, minute: 0),
    TimeOfDay(hour: 19, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    _repo = AppointmentRepositoryImpl(_remote);
    _serviceCtrl = TextEditingController(text: widget.serviceDetails?['serviceName'] ?? 'Hair Cut');
    _priceCtrl = TextEditingController(text: (widget.serviceDetails?['price'] ?? 30).toString());
    _selectedTime = widget.serviceDetails?['initialTime'] as TimeOfDay?;
  }

  @override
  void dispose() {
    _serviceCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  List<DateTime> _nextDays(int count) {
    final now = DateTime.now();
    return List.generate(count, (i) => DateTime(now.year, now.month, now.day).add(Duration(days: i)));
  }

  String _weekdayShort(DateTime d) => DateFormat.E().format(d);
  String _dayNumber(DateTime d) => DateFormat.d().format(d);

  void _onSelectDate(DateTime d) {
    setState(() {
      _selectedDate = d;
      // clear selected time when date changes
      _selectedTime = null;
    });
  }

  void _onSelectTime(TimeOfDay t) {
    setState(() => _selectedTime = t);
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = 'Vui lòng đăng nhập');
      return;
    }
    if (_selectedTime == null) {
      setState(() => _error = 'Chọn giờ trước khi đặt');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    final appointment = Appointment(
      id: '',
      userId: user.uid,
      service: _serviceCtrl.text.trim(),
      date: _combineDateTime(_selectedDate, _selectedTime!),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      color: const Color(0xFF233826),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFF3E8E2),
            child: Image.asset('images/barber2.png', width: 500, height: 500, fit: BoxFit.contain), // provide placeholder asset
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('JOHN DOE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 4),
              Text('Barberman', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: const Color(0xFF233826), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.content_cut, color: Color(0xFFF3E8E2)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_serviceCtrl.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Your selected service', style: TextStyle(color: Colors.grey[700])),
          ]),
        ),
        Text('\$${_priceCtrl.text}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildDateSelector() {
    final days = _nextDays(7);
    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final d = days[index];
          final selected = DateTime(d.year, d.month, d.day) == DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
          return GestureDetector(
            onTap: () => _onSelectDate(d),
            child: Container(
              width: 68,
              margin: const EdgeInsets.only(left: 4, right: 4),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF233826) : const Color(0xFFF3E8E2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: selected ? const Color(0xFF233826) : Colors.grey.shade300),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_weekdayShort(d), style: TextStyle(color: selected ? Colors.white : Colors.black54, fontSize: 12)),
                const SizedBox(height: 6),
                Text(_dayNumber(d), style: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemCount: days.length,
      ),
    );
  }

  Widget _buildTimeGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        children: _timeSlots.map((t) {
          final selected = _selectedTime != null && _selectedTime!.hour == t.hour && _selectedTime!.minute == t.minute;
          return GestureDetector(
            onTap: () => _onSelectTime(t),
            child: Container(
              width: (MediaQuery.of(context).size.width - 56) / 3,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF233826) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: selected ? const Color(0xFF233826) : Colors.grey.shade300),
                boxShadow: selected ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
              ),
              alignment: Alignment.center,
              child: Text(
                MaterialLocalizations.of(context).formatTimeOfDay(t, alwaysUse24HourFormat: false),
                style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8E2),
      body: Column(
        children: [
          _buildHeader(),
          _buildServiceInfo(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(alignment: Alignment.centerLeft, child: Text('CHOOSE YOUR SLOT', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: 6),
          _buildDateSelector(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(alignment: Alignment.centerLeft, child: Text('CHOOSE YOUR TIME', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: 8),
          Expanded(child: SingleChildScrollView(child: _buildTimeGrid())),
          if (_error != null) Padding(padding: const EdgeInsets.all(12), child: Text(_error!, style: const TextStyle(color: Colors.red))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF233826)),
                child: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('BOOK NOW', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}