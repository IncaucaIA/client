import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:incauca_labs/core/colors.dart'; 
import 'bloc/upload_bloc.dart';
import 'bloc/upload_event.dart';
import 'bloc/upload_state.dart';

// PÁGINA DE DETALLE (Placeholder temporal para que funcione la navegación)
class ResultDetailView extends StatelessWidget {
  const ResultDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Análisis')),
      body: const Center(child: Text('Aquí se mostrarán los resultados del análisis')),
    );
  }
}

class UploadView extends StatefulWidget {
  const UploadView({super.key});

  @override
  State<UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends State<UploadView> {
  final ImagePicker _picker = ImagePicker();
  
  // Lista de notificaciones
  final List<String> _notifications = [];
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    context.read<UploadBloc>().add(const WebSocketConnectionRequested());
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null && context.mounted) {
        final File imageFile = File(image.path);
        context.read<UploadBloc>().add(
              UploadImageRequested(
                image: imageFile,
                userId: 'user123',
                tags: ['analysis-request'],
              ),
            );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  // Navegación al detalle
  void _navigateToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResultDetailView()),
    );
  }

  // Modal de Notificaciones Mejorado
  void _showNotificationsModal() {
    setState(() {
      _unreadNotifications = 0; 
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, 
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Resultados de Análisis',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics_outlined, 
                               size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Sin resultados recientes',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.secondary.withOpacity(0.1),
                            child: const Icon(Icons.check_circle_outline, color: AppColors.secondary),
                          ),
                          title: const Text(
                            'Análisis completado',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            _notifications[index], // Mensaje del servidor
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          onTap: () {
                            Navigator.pop(context); // Cerrar modal
                            _navigateToDetail(); // Ir al detalle
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // LISTENER 1: FEEDBACK DE SUBIDA INICIAL
        BlocListener<UploadBloc, UploadState>(
          listenWhen: (prev, curr) => prev.uploadStatus != curr.uploadStatus,
          listener: (context, state) {
            if (state.uploadStatus == UploadStatus.success) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  // Mensaje formal, largo y descriptivo
                  content: Text(
                    'La imagen fue subida correctamente e inició el procesamiento. En breve se le notificará cuando lleguen los resultados.',
                    style: TextStyle(height: 1.4), // Mejor legibilidad
                  ),
                  backgroundColor: AppColors.secondary, // Verde Incauca
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 6), // Tiempo extendido de lectura
                ),
              );
            } else if (state.uploadStatus == UploadStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error en la carga: ${state.errorMessage}'),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),

        // LISTENER 2: NOTIFICACIÓN DE RESULTADOS (SOCKET)
        BlocListener<UploadBloc, UploadState>(
          listenWhen: (prev, curr) => prev.lastNotificationTime != curr.lastNotificationTime,
          listener: (context, state) {
            if (state.lastNotificationMessage != null) {
              setState(() {
                _notifications.insert(0, state.lastNotificationMessage!);
                _unreadNotifications++;
              });
              
              // SnackBar interactivo con Acción
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Se ha terminado de procesar una imagen.'),
                  backgroundColor: AppColors.primary, // Azul corporativo para info
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 8), // Tiempo suficiente para dar click
                  action: SnackBarAction(
                    label: 'VER DETALLE',
                    textColor: AppColors.accent, // Amarillo para resaltar la acción
                    onPressed: _navigateToDetail,
                  ),
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<UploadBloc, UploadState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: AppColors.primary,
              title: const Text(
                'Carga para Análisis', // Título actualizado
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              centerTitle: true,
              actions: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 28),
                      onPressed: _showNotificationsModal,
                    ),
                    if (_unreadNotifications > 0)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accent, // Usamos el amarillo de "Energía"
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$_unreadNotifications',
                            style: const TextStyle(
                              color: AppColors.primary, // Texto oscuro sobre amarillo
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              children: [
                // Banner de conexión (solo si falla)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: !state.isConnected
                      ? Container(
                          width: double.infinity,
                          color: Colors.orange.shade800,
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.wifi_off, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Reconectando servicio de análisis...',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Textos Informativos
                        const Text(
                          'Nuevo Análisis',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary, // Azul Incauca
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Selecciona una imagen de la galería para iniciar el proceso de detección y análisis automatizado.',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: AppColors.dark.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ZONA DE CARGA
                        GestureDetector(
                          onTap: state.uploadStatus == UploadStatus.loading
                              ? null
                              : () => _pickAndUploadImage(context),
                          child: Container(
                            height: 320,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: state.uploadStatus == UploadStatus.loading
                                    ? Colors.grey.shade300
                                    : AppColors.primary.withOpacity(0.2), // Borde sutil
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.08),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: state.uploadStatus == UploadStatus.loading
                                ? _buildLoadingView()
                                : _buildDropZoneView(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropZoneView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_a_photo_outlined, // Icono más "técnico"
            size: 50,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Seleccionar Imagen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Formatos: JPG, PNG',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary, // Verde
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            color: AppColors.secondary,
            strokeWidth: 4,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Subiendo imagen...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Preparando para análisis',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}