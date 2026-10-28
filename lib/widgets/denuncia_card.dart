import 'package:flutter/material.dart';
import '../models/denuncia.dart';

class DenunciaCard extends StatelessWidget {
  final Denuncia denuncia;
  final VoidCallback onTap;

  const DenunciaCard({
    super.key,
    required this.denuncia,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool esPendiente = denuncia.isPendiente;
    final Color estadoColor = esPendiente ? const Color(0xFFD97706) : const Color(0xFF166534);
    final String estadoTexto = esPendiente ? 'Pendiente' : 'Atendida';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila Superior: Tipo y Estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      denuncia.tipo.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2942),
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      estadoTexto,
                      style: TextStyle(
                        color: estadoColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Segunda Fila: Registro #ID · Dirección
              Text(
                'Registro #${denuncia.id ?? '?'} · ${denuncia.direccion}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Tercera Fila: Ver detalle >
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ver detalle',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2942),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
