import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/denuncia.dart';

class DenunciaService {
  static const Duration _timeoutDuration = Duration(seconds: 10);

  // 1. GET /denuncias/?offset=0&limit=5 -> Obtener denuncias paginadas
  Future<List<Denuncia>> getDenunciasPaginadas({int offset = 0, int limit = 5}) async {
    final uri = Uri.parse('${ApiConfig.denunciasEndpoint}?offset=$offset&limit=$limit');
    try {
      final response = await http.get(uri).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> itemsList = [];

        if (decoded is Map<String, dynamic> && decoded.containsKey('content')) {
          itemsList = (decoded['content'] as List<dynamic>?) ?? [];
        } else if (decoded is List<dynamic>) {
          itemsList = decoded;
        }

        return itemsList
            .whereType<Map<String, dynamic>>()
            .map((item) => Denuncia.fromJson(item))
            .toList();
      } else {
        throw Exception('Respuesta de servidor no válida (${response.statusCode})');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado al conectar con ${ApiConfig.baseUrl}. Verifica que Spring Boot esté ejecutándose.');
    } catch (e) {
      if (e is Exception && !e.toString().contains('ClientException')) {
        rethrow;
      }
      throw Exception('No se pudo conectar a ${ApiConfig.baseUrl}. Revisa la conexión a la API.');
    }
  }

  // 2. POST /denuncias/ -> Registrar una nueva denuncia
  Future<Denuncia> registrarDenuncia(Denuncia denuncia) async {
    final uri = Uri.parse(ApiConfig.denunciasEndpoint);
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(denuncia.toJson()),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> body = jsonDecode(response.body);
          return Denuncia.fromJson(body);
        } else {
          return denuncia;
        }
      } else {
        throw Exception('Error al registrar la denuncia (Código ${response.statusCode})');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado al registrar en ${ApiConfig.baseUrl}');
    } catch (e) {
      if (e is Exception && !e.toString().contains('ClientException')) {
        rethrow;
      }
      throw Exception('No se pudo conectar a ${ApiConfig.baseUrl} para guardar la denuncia.');
    }
  }

  // 3. GET /denuncias/{id} -> Obtener datos completos por ID
  Future<Denuncia> getDenunciaById(int id) async {
    final uri = Uri.parse('${ApiConfig.denunciasEndpoint}$id');
    try {
      final response = await http.get(uri).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return Denuncia.fromJson(body);
      } else {
        throw Exception('No se encontró la denuncia con ID $id (Código ${response.statusCode})');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado al consultar la denuncia #$id');
    } catch (e) {
      if (e is Exception && !e.toString().contains('ClientException')) {
        rethrow;
      }
      throw Exception('No se pudo conectar a ${ApiConfig.baseUrl}');
    }
  }

  // 4. GET /denuncias/ciudadano/{dni} -> Buscar denuncias por DNI
  Future<List<Denuncia>> getDenunciasByDni(String dni) async {
    final uri = Uri.parse('${ApiConfig.denunciasEndpoint}ciudadano/$dni');
    try {
      final response = await http.get(uri).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> itemsList = [];

        if (decoded is List<dynamic>) {
          itemsList = decoded;
        } else if (decoded is Map<String, dynamic> && decoded.containsKey('content')) {
          itemsList = (decoded['content'] as List<dynamic>?) ?? [];
        }

        return itemsList
            .whereType<Map<String, dynamic>>()
            .map((item) => Denuncia.fromJson(item))
            .toList();
      } else {
        throw Exception('Error al buscar denuncias del ciudadano (Código ${response.statusCode})');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado al buscar por DNI $dni');
    } catch (e) {
      if (e is Exception && !e.toString().contains('ClientException')) {
        rethrow;
      }
      throw Exception('No se pudo conectar a ${ApiConfig.baseUrl}');
    }
  }

  // 5. PUT /denuncias/{id} -> Cambiar estado de la denuncia a atendida (0)
  Future<Denuncia> atenderDenuncia(int id, {Denuncia? denunciaActual}) async {
    final uri = Uri.parse('${ApiConfig.denunciasEndpoint}$id');

    Map<String, dynamic> bodyPayload;
    if (denunciaActual != null) {
      bodyPayload = denunciaActual.toJson();
      bodyPayload['estado'] = 0;
    } else {
      bodyPayload = {'estado': 0};
    }

    try {
      final response = await http
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(bodyPayload),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic> body = jsonDecode(response.body);
            return Denuncia.fromJson(body);
          } catch (_) {}
        }

        if (denunciaActual != null) {
          return Denuncia(
            id: denunciaActual.id,
            dni: denunciaActual.dni,
            fecha: denunciaActual.fecha,
            tipo: denunciaActual.tipo,
            direccion: denunciaActual.direccion,
            descripcion: denunciaActual.descripcion,
            estado: 0,
          );
        } else {
          return await getDenunciaById(id);
        }
      } else {
        throw Exception('Error al actualizar estado (Código ${response.statusCode})');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado al actualizar la denuncia #$id');
    } catch (e) {
      if (e is Exception && !e.toString().contains('ClientException')) {
        rethrow;
      }
      throw Exception('No se pudo conectar a ${ApiConfig.baseUrl}');
    }
  }
}
