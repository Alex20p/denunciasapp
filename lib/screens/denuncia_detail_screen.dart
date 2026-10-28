import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/denuncia_service.dart';

class DenunciaDetailScreen extends StatefulWidget {
  final int denunciaId;

  const DenunciaDetailScreen({super.key, required this.denunciaId});

  @override
  State<DenunciaDetailScreen> createState() => _DenunciaDetailScreenState();
}

class _DenunciaDetailScreenState extends State<DenunciaDetailScreen> {
  final DenunciaService _denunciaService = DenunciaService();

  late Future<Denuncia> _futureDenuncia;
  Denuncia? _denunciaActual;
  bool _isUpdating = false;
  bool _wasStateChanged = false;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  void _cargarDetalle() {
    setState(() {
      _futureDenuncia = _denunciaService.getDenunciaById(widget.denunciaId);
    });
  }

  Future<void> _marcarComoAtendida() async {
    if (_denunciaActual == null || _isUpdating) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Atención'),
        content: const Text('¿Está seguro de cambiar el estado de esta denuncia a ATENDIDA por serenazgo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF166534)),
            child: const Text('Sí, Atendida'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final denunciaActualizada = await _denunciaService.atenderDenuncia(
        widget.denunciaId,
        denunciaActual: _denunciaActual,
      );

      setState(() {
        _denunciaActual = denunciaActualizada;
        _futureDenuncia = Future.value(denunciaActualizada);
        _isUpdating = false;
        _wasStateChanged = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La denuncia ha sido marcada como ATENDIDA.'),
            backgroundColor: Color(0xFF166534),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _wasStateChanged);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Detalle Denuncia #${widget.denunciaId}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context, _wasStateChanged),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: FutureBuilder<Denuncia>(
              future: _futureDenuncia,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0F2942)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'No se pudo cargar el detalle',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString().replaceAll('Exception: ', ''),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: _cargarDetalle,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final denuncia = snapshot.data!;
                _denunciaActual = denuncia;

                final bool esPendiente = denuncia.isPendiente;
                final Color estadoColor = esPendiente ? const Color(0xFFC2410C) : const Color(0xFF166534);
                final Color estadoBgColor = esPendiente ? const Color(0xFFFFEDD5) : const Color(0xFFDCFCE7);
                final String estadoTexto = esPendiente ? 'PENDIENTE DE ATENCIÓN' : 'ATENDIDA POR SERENAZGO';

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Banner de Estado
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: estadoBgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: estadoColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              esPendiente ? Icons.access_time_filled_rounded : Icons.check_circle_rounded,
                              color: estadoColor,
                              size: 32,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estado Actual',
                                    style: TextStyle(fontSize: 12, color: estadoColor.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    estadoTexto,
                                    style: TextStyle(
                                      color: estadoColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tarjeta con la información detallada
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
                              _buildDetailTile(
                                context,
                                icon: Icons.numbers_rounded,
                                label: 'Código de Registro',
                                value: '#${denuncia.id}',
                              ),
                              const Divider(height: 24, color: Color(0xFFF1F5F9)),
                              _buildDetailTile(
                                context,
                                icon: Icons.shield_outlined,
                                label: 'Tipo de Incidente',
                                value: denuncia.tipo.toUpperCase(),
                                valueStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF0F2942),
                                ),
                              ),
                              const Divider(height: 24, color: Color(0xFFF1F5F9)),
                              _buildDetailTile(
                                context,
                                icon: Icons.badge_outlined,
                                label: 'DNI del Ciudadano',
                                value: denuncia.dni,
                              ),
                              const Divider(height: 24, color: Color(0xFFF1F5F9)),
                              _buildDetailTile(
                                context,
                                icon: Icons.event_outlined,
                                label: 'Fecha y Hora Registrada',
                                value: _formatFecha(denuncia.fecha),
                              ),
                              const Divider(height: 24, color: Color(0xFFF1F5F9)),
                              _buildDetailTile(
                                context,
                                icon: Icons.location_on_outlined,
                                label: 'Dirección o Ubicación',
                                value: denuncia.direccion,
                              ),
                              const Divider(height: 24, color: Color(0xFFF1F5F9)),
                              _buildDetailTile(
                                context,
                                icon: Icons.description_outlined,
                                label: 'Descripción del Hecho',
                                value: denuncia.descripcion,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botón para marcar como atendida (sólo si es pendiente)
                      if (esPendiente)
                        FilledButton.icon(
                          onPressed: _isUpdating ? null : _marcarComoAtendida,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF166534),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: _isUpdating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.shield_outlined),
                          label: Text(
                            _isUpdating ? 'Actualizando...' : 'Marcar como Atendida (Serenazgo)',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF166534).withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified_rounded, color: Color(0xFF166534), size: 22),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Esta denuncia ya fue marcada como atendida.',
                                  style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF0F2942), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: valueStyle ?? const TextStyle(fontSize: 15, color: Color(0xFF1E293B), height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
