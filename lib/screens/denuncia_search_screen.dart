import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/denuncia_service.dart';
import '../widgets/denuncia_card.dart';
import 'denuncia_detail_screen.dart';

class DenunciaSearchScreen extends StatefulWidget {
  const DenunciaSearchScreen({super.key});

  @override
  State<DenunciaSearchScreen> createState() => _DenunciaSearchScreenState();
}

class _DenunciaSearchScreenState extends State<DenunciaSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dniController = TextEditingController();
  final DenunciaService _denunciaService = DenunciaService();

  List<Denuncia>? _resultados;
  bool _isSearching = false;
  String? _errorMessage;
  String? _lastDniBuscado;

  @override
  void dispose() {
    _dniController.dispose();
    super.dispose();
  }

  Future<void> _buscarDenuncias() async {
    if (!_formKey.currentState!.validate()) return;

    final dni = _dniController.text.trim();

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _resultados = null;
      _lastDniBuscado = dni;
    });

    try {
      final denuncias = await _denunciaService.getDenunciasByDni(dni);
      setState(() {
        _resultados = denuncias;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isSearching = false;
      });
    }
  }

  void _navegarADetalle(Denuncia denuncia) async {
    final bool? fueActualizada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DenunciaDetailScreen(denunciaId: denuncia.id ?? 0),
      ),
    );

    if (fueActualizada == true && _lastDniBuscado != null) {
      _buscarDenuncias();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Búsqueda por DNI'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Barra de Búsqueda
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dniController,
                          keyboardType: TextInputType.number,
                          maxLength: 8,
                          decoration: const InputDecoration(
                            labelText: 'DNI del Ciudadano',
                            hintText: '8 dígitos numéricos',
                            prefixIcon: Icon(Icons.badge_outlined),
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingrese un DNI';
                            }
                            if (value.trim().length != 8 || int.tryParse(value.trim()) == null) {
                              return 'DNI inválido (8 números)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _isSearching ? null : _buscarDenuncias,
                        icon: _isSearching
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.search_rounded),
                        label: const Text('Buscar'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Área de Resultados
              Expanded(
                child: _buildResultadosArea(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultadosArea() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0F2942)),
            SizedBox(height: 16),
            Text(
              'Consultando denuncias del ciudadano...',
              style: TextStyle(color: Color(0xFF334155)),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error al Buscar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2942)),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _buscarDenuncias,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_resultados == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_outlined, size: 64, color: Color(0xFF94A3B8)),
            SizedBox(height: 16),
            Text(
              'Ingrese un DNI de 8 dígitos para ver su historial',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (_resultados!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.find_in_page_outlined, size: 64, color: Color(0xFF94A3B8)),
              const SizedBox(height: 16),
              Text(
                'No se encontraron denuncias para el DNI $_lastDniBuscado',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2942)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Text(
            'Se encontraron ${_resultados!.length} denuncia(s) para el DNI $_lastDniBuscado:',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 13),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            itemCount: _resultados!.length,
            itemBuilder: (context, index) {
              final denuncia = _resultados![index];
              return DenunciaCard(
                denuncia: denuncia,
                onTap: () => _navegarADetalle(denuncia),
              );
            },
          ),
        ),
      ],
    );
  }
}
