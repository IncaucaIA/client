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
      body: // En tu build:
BlocConsumer<UploadBloc, UploadState>(
  listenWhen: (previous, current) {
    // Solo escuchar si cambia el status o llega una nueva notificación
    return previous.uploadStatus != current.uploadStatus ||
           previous.lastNotificationTime != current.lastNotificationTime;
  },
  listener: (context, state) {
    // Manejo de Upload
    if (state.uploadStatus == UploadStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Image uploaded: ${state.document?.image.url}'), backgroundColor: Colors.green),
      );
    } else if (state.uploadStatus == UploadStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${state.errorMessage}'), backgroundColor: Colors.red),
      );
    }

    // Manejo de Notificaciones
    // Verificamos que el mensaje no sea null y que sea "nuevo" (diferente timestamp)
    if (state.lastNotificationMessage != null && 
        state.lastNotificationTime != null) {
      
      // Actualizamos la lista local
      setState(() {
        _notifications.insert(0, '[${state.lastNotificationTime!.toLocal()}] ${state.lastNotificationMessage}');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📩 ${state.lastNotificationMessage}'),
          backgroundColor: Colors.purple,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  },
  builder: (context, state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Connection Status Card
          Card(
            // Ahora simplemente verificamos la propiedad booleana
            color: state.isConnected ? Colors.green.shade50 : Colors.orange.shade50,
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
                    state.isConnected ? 'Connected to Web PubSub' : 'Connecting/Disconnected...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          ElevatedButton.icon(
            // Bloqueamos botón si está subiendo
            onPressed: state.uploadStatus == UploadStatus.loading
                ? null
                : () => _pickAndUploadImage(context),
            icon: const Icon(Icons.upload_file),
            label: Text(state.uploadStatus == UploadStatus.loading
                ? 'Uploading...'
                : 'Select & Upload Image'),
          ),
          
          if (state.uploadStatus == UploadStatus.loading)
             const LinearProgressIndicator(),
             
          // ... Resto de tu UI (Lista de notificaciones)
        ],
      ),
    );
  },
),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickAndUploadImage(context),
        tooltip: 'Upload Image',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  @override
  void dispose() {
    context.read<UploadBloc>().add(const WebSocketDisconnectionRequested());
    super.dispose();
  }
}
