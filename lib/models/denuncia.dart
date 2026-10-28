class Denuncia {
  final int? id;
  final String dni;
  final DateTime fecha;
  final String tipo;
  final String direccion;
  final String descripcion;
  final int estado; // 1: pendiente, 0: atendida

  Denuncia({
    this.id,
    required this.dni,
    required this.fecha,
    required this.tipo,
    required this.direccion,
    required this.descripcion,
    this.estado = 1,
  });

  bool get isPendiente => estado == 1;
  bool get isAtendida => estado == 0;

  factory Denuncia.fromJson(Map<String, dynamic> json) {
    DateTime parsedFecha;
    if (json['fecha'] != null) {
      if (json['fecha'] is String) {
        final strVal = json['fecha'] as String;
        // Reemplaza espacio por 'T' para asegurar parseo estándar en Dart (yyyy-MM-dd HH:mm:ss -> yyyy-MM-ddTHH:mm:ss)
        final normalizedStr = strVal.contains(' ') ? strVal.replaceAll(' ', 'T') : strVal;
        parsedFecha = DateTime.tryParse(normalizedStr) ?? DateTime.tryParse(strVal) ?? DateTime.now();
      } else if (json['fecha'] is List && (json['fecha'] as List).isNotEmpty) {
        // En caso de que Spring Boot Jackson serialice como array [YYYY, MM, DD, hh, mm, ss]
        List<dynamic> f = json['fecha'];
        parsedFecha = DateTime(
          f[0] as int,
          f.length > 1 ? f[1] as int : 1,
          f.length > 2 ? f[2] as int : 1,
          f.length > 3 ? f[3] as int : 0,
          f.length > 4 ? f[4] as int : 0,
          f.length > 5 ? f[5] as int : 0,
        );
      } else {
        parsedFecha = DateTime.now();
      }
    } else {
      parsedFecha = DateTime.now();
    }

    return Denuncia(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      dni: json['dni']?.toString() ?? '',
      fecha: parsedFecha,
      tipo: json['tipo']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      estado: json['estado'] is int
          ? json['estado']
          : int.tryParse(json['estado']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    // Formato 'yyyy-MM-dd HH:mm:ss' para compatibilidad con Spring Boot / Jackson
    final String y = fecha.year.toString().padLeft(4, '0');
    final String m = fecha.month.toString().padLeft(2, '0');
    final String d = fecha.day.toString().padLeft(2, '0');
    final String hh = fecha.hour.toString().padLeft(2, '0');
    final String mm = fecha.minute.toString().padLeft(2, '0');
    final String ss = fecha.second.toString().padLeft(2, '0');
    final String fechaFormateada = '$y-$m-$d $hh:$mm:$ss';

    final Map<String, dynamic> data = {
      'dni': dni,
      'fecha': fechaFormateada,
      'tipo': tipo,
      'direccion': direccion,
      'descripcion': descripcion,
      'estado': estado,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
