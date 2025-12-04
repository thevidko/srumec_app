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

  // Controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _latController = TextEditingController(text: "50.087"); // Default Praha
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
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Výběr času
  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
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

    // Spojení Date a Time do jednoho DateTime
    final finalDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Získání dat (konverze lat/lng na double)
    final lat =
        double.tryParse(_latController.text.replaceAll(',', '.')) ?? 0.0;
    final lng =
        double.tryParse(_lngController.text.replaceAll(',', '.')) ?? 0.0;

    try {
      // 2. ZÍSKÁNÍ REPOZITÁŘE Z PROVIDERA (Dependency Injection)
      // -----------------------------------------------------
      // Díky tomu použijeme tu instanci, která má Dio s Interceptorem (a tokenem)
      final repository = context.read<EventsRepository>();

      final success = await repository.createEvent(
        title: _titleController.text,
        description: _descController.text,
        latitude: lat,
        longitude: lng,
        happenTime: finalDateTime,
        userId: userId, // <--- Použijeme ID z providera
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Událost úspěšně vytvořena!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Návrat zpět
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

  // Metoda 1: Získat z GPS (LocationProvider)
  Future<void> _useCurrentLocation() async {
    final locProvider = context.read<LocationProvider>();

    // Zobrazíme loading nebo toast, že se zaměřuje
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

  // Metoda 2: Otevřít mapu
  Future<void> _pickFromMap() async {
    // Zkusíme vzít aktuální hodnoty z inputů pro startovní pozici mapy
    final currentLat = double.tryParse(_latController.text);
    final currentLng = double.tryParse(_lngController.text);
    LatLng? startPos;

    if (currentLat != null && currentLng != null) {
      startPos = LatLng(currentLat, currentLng);
    }

    // Otevřeme picker a čekáme na výsledek
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(initialLocation: startPos),
      ),
    );

    // Pokud uživatel něco vybral, aktualizujeme UI
    if (result != null) {
      setState(() {
        _latController.text = result.latitude.toString();
        _lngController.text = result.longitude.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nová událost")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // NÁZEV
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Název akce',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Zadejte název' : null,
              ),
              const SizedBox(height: 16),

              // POPIS
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Popis',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Zadejte popis' : null,
              ),
              const SizedBox(height: 16),

              // DATUM A ČAS (Row)
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                "Místo konání",
                style: TextStyle(fontWeight: FontWeight.bold),
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
                        backgroundColor: Colors.blue[50],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickFromMap,
                      icon: const Icon(Icons.map),
                      label: const Text("Vybrat z mapy"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // TLAČÍTKO ODESLAT
              FilledButton(
                onPressed: _isLoading ? null : _submitForm,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
