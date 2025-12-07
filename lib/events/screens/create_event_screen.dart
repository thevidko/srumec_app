import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:srumec_app/auth/providers/auth_provider.dart';
import 'package:srumec_app/core/providers/locator/location_provider.dart';
import 'package:srumec_app/events/data/repositories/event_repository.dart';
import 'package:provider/provider.dart';
import 'package:srumec_app/events/screens/widgets/location_picker_screen.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  static const Color vibrantPurple = Color(0xFF6200EA);

  // Controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _latController = TextEditingController(text: "50.087");
  final _lngController = TextEditingController(text: "14.420");

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  // Výběr data
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: vibrantPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Výběr času
  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: vibrantPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vyberte prosím datum a čas konání.')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chyba: Uživatel není identifikován (chybí ID).'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final finalDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final lat =
        double.tryParse(_latController.text.replaceAll(',', '.')) ?? 0.0;
    final lng =
        double.tryParse(_lngController.text.replaceAll(',', '.')) ?? 0.0;

    try {
      final repository = context.read<EventsRepository>();
      final success = await repository.createEvent(
        title: _titleController.text,
        description: _descController.text,
        latitude: lat,
        longitude: lng,
        happenTime: finalDateTime,
        userId: userId,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Událost úspěšně vytvořena!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nepodařilo se vytvořit událost.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Chyba: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    final locProvider = context.read<LocationProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Zjišťuji polohu...'),
        duration: Duration(seconds: 1),
      ),
    );

    await locProvider.determinePosition();

    if (locProvider.currentPosition != null) {
      setState(() {
        _latController.text = locProvider.currentPosition!.latitude.toString();
        _lngController.text = locProvider.currentPosition!.longitude.toString();
      });
    } else if (locProvider.errorMessage != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chyba: ${locProvider.errorMessage}')),
      );
    }
  }

  Future<void> _pickFromMap() async {
    final currentLat = double.tryParse(_latController.text);
    final currentLng = double.tryParse(_lngController.text);
    LatLng? startPos;

    if (currentLat != null && currentLng != null) {
      startPos = LatLng(currentLat, currentLng);
    }

    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(initialLocation: startPos),
      ),
    );

    if (result != null) {
      setState(() {
        _latController.text = result.latitude.toString();
        _lngController.text = result.longitude.toString();
      });
    }
  }

  // Pomocná metoda pro styl inputů
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      floatingLabelStyle: const TextStyle(
        color: vibrantPurple,
      ), // Fialový label při psaní
      prefixIcon: Icon(icon, color: vibrantPurple), // Fialová ikona
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: vibrantPurple, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nová událost",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: vibrantPurple, // Sladění s MainScreen
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // NÁZEV
              TextFormField(
                controller: _titleController,
                cursorColor: vibrantPurple,
                decoration: _inputDecoration('Název akce', Icons.title),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Zadejte název' : null,
              ),
              const SizedBox(height: 16),

              // POPIS
              TextFormField(
                controller: _descController,
                maxLines: 3,
                cursorColor: vibrantPurple,
                decoration: _inputDecoration('Popis', Icons.description),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Zadejte popis' : null,
              ),
              const SizedBox(height: 20),

              // DATUM A ČAS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _selectedDate == null
                            ? 'Datum'
                            : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: vibrantPurple, // Fialový text a ikona
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: _selectedDate != null
                              ? vibrantPurple
                              : Colors.grey.shade400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _selectedTime == null
                            ? 'Čas'
                            : _selectedTime!.format(context),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: vibrantPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: _selectedTime != null
                              ? vibrantPurple
                              : Colors.grey.shade400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                "Místo konání",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Tlačítka pro výběr
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _useCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text("Moje poloha"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vibrantPurple.withOpacity(0.1),
                        foregroundColor: vibrantPurple,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickFromMap,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text("Vybrat z mapy"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vibrantPurple.withOpacity(0.1),
                        foregroundColor: vibrantPurple,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // TLAČÍTKO ODESLAT
              FilledButton(
                onPressed: _isLoading ? null : _submitForm,
                style: FilledButton.styleFrom(
                  backgroundColor: vibrantPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Vytvořit událost",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
