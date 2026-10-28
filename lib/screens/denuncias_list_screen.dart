import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/denuncia.dart';
import '../services/denuncia_service.dart';
import '../widgets/denuncia_card.dart';
import 'denuncia_detail_screen.dart';
import 'denuncia_form_screen.dart';
import 'denuncia_search_screen.dart';

class DenunciasListScreen extends StatefulWidget {
  const DenunciasListScreen({super.key});

  @override
  State<DenunciasListScreen> createState() => _DenunciasListScreenState();
}

class _DenunciasListScreenState extends State<DenunciasListScreen> {
  final DenunciaService _denunciaService = DenunciaService();
  final List<Denuncia> _denuncias = [];

  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _errorMessage;

  static const int _limit = 5;
  int _currentOffset = 0;

  @override
  void initState() {
    super.initState();
    _cargarDenunciasIniciales();
  }

  Future<void> _cargarDenunciasIniciales() async {
    setState(() {
      _isLoadingInitial = true;
      _errorMessage = null;
      _currentOffset = 0;
      _denuncias.clear();
      _hasMoreData = true;
    });

    try {
      final nuevasDenuncias = await _denunciaService.getDenunciasPaginadas(
        offset: _currentOffset,
        limit: _limit,
      );

      setState(() {
        for (final nueva in nuevasDenuncias) {
          if (nueva.id == null || !_denuncias.any((existing) => existing.id == nueva.id)) {
            _denuncias.add(nueva);
          }
        }
        _isLoadingInitial = false;
        if (nuevasDenuncias.length < _limit) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoadingInitial = false;
      });
    }
  }

  Future<void> _cargarMasDenuncias() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    final proximoOffset = _currentOffset + _limit;

    try {
      final nuevasDenuncias = await _denunciaService.getDenunciasPaginadas(
        offset: proximoOffset,
        limit: _limit,
      );

      setState(() {
        _currentOffset = proximoOffset;
        int agregadasNuevas = 0;
        for (final nueva in nuevasDenuncias) {
          if (nueva.id == null || !_denuncias.any((existing) => existing.id == nueva.id)) {
            _denuncias.add(nueva);
            agregadasNuevas++;
          }
        }
        _isLoadingMore = false;
        if (nuevasDenuncias.length < _limit || agregadasNuevas == 0) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar más denuncias: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarDialogoConfiguracionApi() {
    final controller = TextEditingController(text: ApiConfig.baseUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración del Servidor API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Servidor activo:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'URL Base de la API',
                hintText: 'http://localhost:8080',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Guía de conexión:\n'
              '• Web / Windows: http://localhost:8080\n'
              '• Emulador Android: http://10.0.2.2:8080\n'
              '• Celular USB: http://127.0.0.1:8080 (ADB Reverse)',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ApiConfig.setCustomBaseUrl(null);
              Navigator.pop(context);
              _cargarDenunciasIniciales();
            },
            child: const Text('Restablecer'),
          ),
          FilledButton(
            onPressed: () {
              ApiConfig.setCustomBaseUrl(controller.text);
              Navigator.pop(context);
              _cargarDenunciasIniciales();
            },
            child: const Text('Guardar y Probar'),
          ),
        ],
      ),
    );
  }

  void _navegarADetalle(Denuncia denuncia) async {
    final bool? fueActualizada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DenunciaDetailScreen(denunciaId: denuncia.id ?? 0),
      ),
    );

    if (fueActualizada == true) {
      _cargarDenunciasIniciales();
    }
  }

  void _navegarARegistro() async {
    final bool? creada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const DenunciaFormScreen(),
      ),
    );

    if (creada == true) {
      _cargarDenunciasIniciales();
    }
  }

  void _navegarABusqueda() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DenunciaSearchScreen(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2942),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Denuncias Ciudadanas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestión de incidencias',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: 'Actualizar',
                onPressed: _cargarDenunciasIniciales,
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                tooltip: 'Configurar Servidor API',
                onPressed: _mostrarDialogoConfiguracionApi,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesPrincipales(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Botón "Nueva denuncia"
          Expanded(
            child: Material(
              color: const Color(0xFF0F2942),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: _navegarARegistro,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 22),
                      SizedBox(height: 6),
                      Text(
                        'Nueva denuncia',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Botón "Buscar por DNI"
          Expanded(
            child: Material(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: _navegarABusqueda,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_rounded, color: Colors.white, size: 22),
                      SizedBox(height: 6),
                      Text(
                        'Buscar por DNI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Listado de denuncias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F2942),
            ),
          ),
          Text(
            '5 por página',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    if (_isLoadingInitial) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF0F2942)),
                SizedBox(height: 16),
                Text(
                  'Cargando denuncias...',
                  style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.signal_wifi_off_rounded, size: 56, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Error de Conexión con el Servidor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2942)),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _mostrarDialogoConfiguracionApi,
                      icon: const Icon(Icons.settings),
                      label: const Text('Servidor API'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _cargarDenunciasIniciales,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_denuncias.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 56, color: Color(0xFF94A3B8)),
                SizedBox(height: 16),
                Text(
                  'No hay denuncias registradas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2942)),
                ),
                SizedBox(height: 6),
                Text(
                  'Utilice el botón "Nueva denuncia" para registrar una incidencia.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < _denuncias.length) {
            final denuncia = _denuncias[index];
            return DenunciaCard(
              denuncia: denuncia,
              onTap: () => _navegarADetalle(denuncia),
            );
          } else {
            // Botón de Paginación "Cargar 5 más v"
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Center(
                child: _hasMoreData
                    ? (_isLoadingMore
                        ? const CircularProgressIndicator(color: Color(0xFF0F2942))
                        : OutlinedButton.icon(
                            onPressed: _cargarMasDenuncias,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            label: const Text('Cargar 5 más'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0F2942),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ))
                    : const Text(
                        'No hay más denuncias para mostrar',
                        style: TextStyle(color: Color(0xFF64748B), fontStyle: FontStyle.italic, fontSize: 13),
                      ),
              ),
            );
          }
        },
        childCount: _denuncias.length + 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: RefreshIndicator(
              onRefresh: _cargarDenunciasIniciales,
              child: CustomScrollView(
                slivers: [
                  // 1. Encabezado Institucional con botones de configuración y recarga
                  SliverToBoxAdapter(
                    child: _buildHeader(context),
                  ),
                  // 2. Acciones principales: "Nueva denuncia" y "Buscar por DNI"
                  SliverToBoxAdapter(
                    child: _buildAccionesPrincipales(context),
                  ),
                  // 3. Título de sección "Listado de denuncias"
                  SliverToBoxAdapter(
                    child: _buildListHeader(),
                  ),
                  // 4. Contenido del listado (Cargando / Error / Vacío / Tarjetas)
                  _buildListContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
