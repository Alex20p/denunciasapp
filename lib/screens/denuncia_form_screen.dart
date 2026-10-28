import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/denuncia_service.dart';

class DenunciaFormScreen extends StatefulWidget {
  const DenunciaFormScreen({super.key});

  @override
  State<DenunciaFormScreen> createState() => _DenunciaFormScreenState();
}

class _DenunciaFormScreenState extends State<DenunciaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DenunciaService _denunciaService = DenunciaService();

  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  DateTime _selectedFecha = DateTime.now();
  String _selectedTipo = 'ROBO';
  bool _isSubmitting = false;

  final List<String> _tiposIncidente = [
    'ROBO',
    'ASALTO',
    'VANDALISMO',
    'ACCIDENTE',
    'OTRO',
  ];

  @override
  void dispose() {
    _dniController.dispose();
    _direccionController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _selectFecha() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedFecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedFecha),
      );

      if (mounted) {
        setState(() {
          _selectedFecha = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime?.hour ?? 0,
            pickedTime?.minute ?? 0,
          );
        });
      }
    }
  }

  String _formatFecha(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Future<void> _guardarDenuncia() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final nuevaDenuncia = Denuncia(
      dni: _dniController.text.trim(),
      fecha: _selectedFecha,
      tipo: _selectedTipo,
      direccion: _direccionController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      estado: 1, // Pendiente por defecto
    );

    try {
      await _denunciaService.registrarDenuncia(nuevaDenuncia);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Denuncia registrada correctamente!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Denuncia'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.add_alert_rounded,
                                  color: Color(0xFF0F2942),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Registro de Incidencia',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F2942),
                                      ),
                                    ),
                                    Text(
                                      'Complete los campos solicitados para enviar la denuncia.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                          ),

                          // Campo DNI del Ciudadano
                          const Text(
                            'Identificación del Ciudadano',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _dniController,
                            keyboardType: TextInputType.number,
                            maxLength: 8,
                            decoration: const InputDecoration(
                              labelText: 'DNI del Ciudadano *',
                              hintText: '8 dígitos numéricos',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El DNI es obligatorio';
                              }
                              if (value.trim().length != 8 || int.tryParse(value.trim()) == null) {
                                return 'El DNI debe tener exactamente 8 dígitos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Información del Incidente
                          const Text(
                            'Detalles de la Denuncia',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 8),

                          // Dropdown Tipo
                          DropdownButtonFormField<String>(
                            initialValue: _selectedTipo,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de Incidente *',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: _tiposIncidente.map((String tipo) {
                              return DropdownMenuItem<String>(
                                value: tipo,
                                child: Text(tipo),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedTipo = newValue;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Selector Fecha y Hora
                          InkWell(
                            onTap: _selectFecha,
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha y Hora del Suceso *',
                                prefixIcon: Icon(Icons.calendar_today_outlined),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatFecha(_selectedFecha),
                                    style: const TextStyle(fontSize: 15, color: Color(0xFF0F2942)),
                                  ),
                                  const Icon(Icons.arrow_drop_down_rounded),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Dirección
                          TextFormField(
                            controller: _direccionController,
                            maxLength: 200,
                            decoration: const InputDecoration(
                              labelText: 'Dirección o Ubicación *',
                              hintText: 'Ej: Av. Principal 123, Urb. Los Olivos',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La dirección es obligatoria';
                              }
                              if (value.trim().length > 200) {
                                return 'Máximo 200 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Descripción
                          TextFormField(
                            controller: _descripcionController,
                            maxLength: 255,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Descripción del Hecho *',
                              hintText: 'Describa lo sucedido en detalle...',
                              prefixIcon: Icon(Icons.description_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La descripción es obligatoria';
                              }
                              if (value.trim().length > 255) {
                                return 'Máximo 255 caracteres';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón Enviar
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _guardarDenuncia,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      _isSubmitting ? 'Procesando...' : 'Enviar Denuncia',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
