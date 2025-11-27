import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'bloc/upload_bloc.dart';
import 'bloc/upload_event.dart';
import 'bloc/upload_state.dart';

class UploadView extends StatefulWidget {
  const UploadView({super.key});

  @override
  State<UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends State<UploadView> {
  final ImagePicker _picker = ImagePicker();
  final List<String> _notifications = [];

  @override
  void initState() {
    super.initState();
    // Connect to WebSocket on initialization
    context.read<UploadBloc>().add(const WebSocketConnectionRequested());
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final File imageFile = File(image.path);
        if (context.mounted) {
          context.read<UploadBloc>().add(
                UploadImageRequested(
                  image: imageFile,
                  userId: 'user123', // TODO: Replace with actual user ID
                  tags: ['mobile-upload'],
                ),
              );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incauca Labs - Image Upload'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // Usamos MultiBlocListener para separar las reacciones
      body: MultiBlocListener(
        listeners: [
          // LISTENER 1: Solo maneja el éxito/fallo de la SUBIDA PROPIA
          BlocListener<UploadBloc, UploadState>(
            listenWhen: (previous, current) {
              // Solo se activa si el estado de subida CAMBIÓ
              return previous.uploadStatus != current.uploadStatus;
            },
            listener: (context, state) {
              if (state.uploadStatus == UploadStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Tu imagen se subió correctamente: ${state.document?.image.url}'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state.uploadStatus == UploadStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Falló tu subida: ${state.errorMessage}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),

          // LISTENER 2: Solo maneja NOTIFICACIONES (Sockets)
          BlocListener<UploadBloc, UploadState>(
            listenWhen: (previous, current) {
              // Solo se activa si el timestamp de la notificación cambió
              return previous.lastNotificationTime != current.lastNotificationTime;
            },
            listener: (context, state) {
              if (state.lastNotificationMessage != null) {
                // Actualizamos la lista visual
                setState(() {
                  _notifications.insert(
                    0,
                    '[${state.lastNotificationTime!.toLocal()}] ${state.lastNotificationMessage}',
                  );
                });
                
                // Mostramos el SnackBar de notificación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('📩 Nueva alerta: ${state.lastNotificationMessage}'),
                    backgroundColor: Colors.purple,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
        ],
        // BUILDER: Solo se encarga de dibujar la UI, no de los SnackBars
        child: BlocBuilder<UploadBloc, UploadState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Tarjeta de Estado de Conexión ---
                  Card(
                    color: state.isConnected
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            state.isConnected ? Icons.cloud_done : Icons.cloud_off,
                            color: state.isConnected ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            state.isConnected
                                ? 'Conectado a Web PubSub'
                                : 'Desconectado / Conectando...',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Botón de Subida ---
                  ElevatedButton.icon(
                    // Bloqueamos si está cargando
                    onPressed: state.uploadStatus == UploadStatus.loading
                        ? null
                        : () => _pickAndUploadImage(context),
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      state.uploadStatus == UploadStatus.loading
                          ? 'Subiendo...'
                          : 'Seleccionar y Subir Imagen',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),

                  if (state.uploadStatus == UploadStatus.loading)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: LinearProgressIndicator(),
                    ),

                  const SizedBox(height: 24),

                  // --- Sección de Notificaciones ---
                  const Text(
                    'Notificaciones en Tiempo Real',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: _notifications.isEmpty
                        ? const Center(
                            child: Text(
                              'Sin notificaciones.\nLas alertas de otros usuarios aparecerán aquí.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.notifications_active,
                                    color: Colors.purple,
                                  ),
                                  title: Text(_notifications[index]),
                                  dense: true,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickAndUploadImage(context),
        tooltip: 'Upload Image',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}