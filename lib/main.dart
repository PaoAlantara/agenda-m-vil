import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MiAgendaApp());
}

class MiAgendaApp extends StatelessWidget {
  const MiAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Agenda Simple',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0FDF4),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF166534)),
      ),
      home: const AgendaScreen(),
    );
  }
}

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final TextEditingController _controlador = TextEditingController();
  List<dynamic> _recordatorios = [];
  bool _cargando = true;

  // Variables para guardar lo que el usuario elija en el calendario
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  final String apiUrl = 'http://10.0.2.2:8000/api/recordatorios';

  @override
  void initState() {
    super.initState();
    _obtenerRecordatorios();
  }

  // 1. LEER DATOS
  Future<void> _obtenerRecordatorios() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _recordatorios = jsonDecode(response.body);
          _cargando = false;
        });
      }
    } catch (e) {
      print("Error conectando a Laravel: $e");
      setState(() => _cargando = false);
    }
  }

  // 2. ABRIR EL CALENDARIO Y RELOJ NATIVO
  Future<void> _seleccionarFechaYHora() async {
    // Abre el calendario
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // No dejar elegir fechas en el pasado
      lastDate: DateTime(2100),
    );

    if (fecha != null) {
      // Si elige fecha, le pregunta la hora
      final TimeOfDay? hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      setState(() {
        _fechaSeleccionada = fecha;
        _horaSeleccionada = hora;
      });
    }
  }

  // 3. GUARDAR NUEVO RECORDATORIO (AHORA CON FECHA)
  Future<void> _guardarRecordatorio(String nombre) async {
    if (nombre.trim().isEmpty) return;
    
    // Preparar los datos exactos que Laravel espera
    Map<String, dynamic> datos = {'nombre': nombre};
    
    if (_fechaSeleccionada != null) {
      datos['fecha_limite'] = "${_fechaSeleccionada!.year}-${_fechaSeleccionada!.month.toString().padLeft(2, '0')}-${_fechaSeleccionada!.day.toString().padLeft(2, '0')}";
    }
    if (_horaSeleccionada != null) {
      datos['hora'] = "${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}";
    }

    _controlador.clear();
    setState(() {
      _fechaSeleccionada = null; // Limpiar después de guardar
      _horaSeleccionada = null;
    });

    try {
      await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos),
      );
      _obtenerRecordatorios(); 
    } catch (e) {
      print("Error al guardar: $e");
    }
  }

  // 4. ELIMINAR RECORDATORIO
  Future<void> _eliminarRecordatorio(int id) async {
    try {
      await http.delete(Uri.parse('$apiUrl/$id'));
      _obtenerRecordatorios();
    } catch (e) {
      print("Error al eliminar: $e");
    }
  }

  Color _obtenerColor(String? fechaLimite) {
    if (fechaLimite == null) return Colors.grey;
    DateTime fecha = DateTime.parse(fechaLimite);
    DateTime hoy = DateTime.now();
    DateTime manana = hoy.add(const Duration(days: 1));

    if (fecha.year == hoy.year && fecha.month == hoy.month && fecha.day == hoy.day) {
      return Colors.redAccent; 
    } else if (fecha.year == manana.year && fecha.month == manana.month && fecha.day == manana.day) {
      return Colors.amber; 
    } else if (fecha.isAfter(hoy)) {
      return Colors.green; 
    }
    return Colors.grey; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Agenda', style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ZONA DE ENTRADA CON CALENDARIO
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controlador,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _guardarRecordatorio,
                        decoration: InputDecoration(
                          hintText: '¿Qué necesitas recordar?',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // BOTÓN DE CALENDARIO
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.calendar_month, color: Color(0xFF166534)),
                        onPressed: _seleccionarFechaYHora,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // BOTÓN DE ENVIAR
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF166534),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () => _guardarRecordatorio(_controlador.text),
                      ),
                    ),
                  ],
                ),
                // Mostrar un pequeño texto si el usuario eligió una fecha antes de enviar
                if (_fechaSeleccionada != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      "📅 Para: ${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year} " +
                      (_horaSeleccionada != null ? "⏱️ ${_horaSeleccionada!.format(context)}" : ""),
                      style: const TextStyle(color: Color(0xFF166534), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
              ],
            ),
          ),

          // LISTA DE RECORDATORIOS
          Expanded(
            child: _cargando 
              ? const Center(child: CircularProgressIndicator())
              : _recordatorios.isEmpty
                ? const Center(child: Text("No hay pendientes. ¡Descansa!", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _recordatorios.length,
                    itemBuilder: (context, index) {
                      final item = _recordatorios[index];
                      
                      // Construir el texto de fecha y hora para la lista
                      String infoExtra = "";
                      if (item['fecha_limite'] != null) infoExtra += item['fecha_limite'];
                      if (item['hora'] != null) infoExtra += " • ${item['hora'].substring(0, 5)}"; // Cortar los segundos

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: _obtenerColor(item['fecha_limite']), width: 5)),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: item['estado'] == 1,
                              onChanged: (val) {},
                              activeColor: const Color(0xFF166534),
                            ),
                            title: Text(item['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                            subtitle: infoExtra.isNotEmpty ? Text(infoExtra) : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey),
                              onPressed: () => _eliminarRecordatorio(item['id']),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
