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
      body: BlocConsumer<UploadBloc, UploadState>(
        listener: (context, state) {
          if (state is UploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Image uploaded: ${state.document.image.url}'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is UploadFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Upload failed: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is WebSocketConnected) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Connected to real-time notifications'),
                backgroundColor: Colors.blue,
              ),
            );
          } else if (state is NotificationReceivedState) {
            setState(() {
              _notifications.insert(
                0,
                '[${state.timestamp.toLocal()}] ${state.message}',
              );
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('📩 New notification: ${state.message}'),
                backgroundColor: Colors.purple,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Connection Status Card
                Card(
                  color: state is WebSocketConnected
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          state is WebSocketConnected
                              ? Icons.cloud_done
                              : Icons.cloud_off,
                          color: state is WebSocketConnected
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state is WebSocketConnected
                              ? 'Connected to Web PubSub'
                              : 'Connecting...',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Upload Button
                ElevatedButton.icon(
                  onPressed: state is UploadInProgress
                      ? null
                      : () => _pickAndUploadImage(context),
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    state is UploadInProgress
                        ? 'Uploading...'
                        : 'Select & Upload Image',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),

                if (state is UploadInProgress)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: LinearProgressIndicator(),
                  ),

                const SizedBox(height: 24),

                // Notifications Section
                const Text(
                  'Real-time Notifications',
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
                            'No notifications yet.\nUpload an image to see real-time updates!',
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
