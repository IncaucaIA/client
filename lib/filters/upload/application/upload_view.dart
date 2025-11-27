import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:incauca_labs/core/colors.dart';
import 'bloc/upload_bloc.dart';
import 'bloc/upload_event.dart';
import 'bloc/upload_state.dart';

class LocalNotification {
  final String message;
  final DateTime timestamp;
  bool isRead;

  LocalNotification({
    required this.message, 
    required this.timestamp, 
    this.isRead = false
  });
}

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
  
  // Usamos la nueva clase en lugar de String
  final List<LocalNotification> _notifications = [];
  
  // Getter para calcular no leídas dinámicamente
  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

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

  void _navigateToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResultDetailView()),
    );
  }

  // --- MODAL DE NOTIFICACIONES ---
  void _showNotificationsModal() {
    // Al abrir el modal, marcamos todas como leídas visualmente tras un pequeño delay
    // o simplemente las mostramos. Si quieres que al abrir se marquen todas:
    setState(() {
       for (var n in _notifications) {
         n.isRead = true;
       }
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
                      padding: const EdgeInsets.all(0), // Padding controlado en items
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return Container(
                          // Fondo sutil si no está leída (por si abrimos modal sin marcar todo)
                          color: notification.isRead ? Colors.transparent : AppColors.primary.withOpacity(0.05),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.secondary.withOpacity(0.1),
                              child: const Icon(Icons.check_circle_outline, color: AppColors.secondary),
                            ),
                            title: Text(
                              'Análisis completado',
                              style: TextStyle(
                                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                color: AppColors.dark,
                              ),
                            ),
                            subtitle: Text(
                              notification.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: notification.isRead ? Colors.grey : AppColors.dark,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${notification.timestamp.hour}:${notification.timestamp.minute.toString().padLeft(2, '0')}",
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _navigateToDetail();
                            },
                          ),
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
        // LISTENER 1: FEEDBACK DE SUBIDA INICIAL (Igual que antes)
        BlocListener<UploadBloc, UploadState>(
          listenWhen: (prev, curr) => prev.uploadStatus != curr.uploadStatus,
          listener: (context, state) {
            if (state.uploadStatus == UploadStatus.success) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'La imagen fue subida correctamente e inició el procesamiento. En breve se le notificará cuando lleguen los resultados.',
                    style: TextStyle(height: 1.4),
                  ),
                  backgroundColor: AppColors.secondary,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 6),
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

        // LISTENER 2: NOTIFICACIÓN DE RESULTADOS
        BlocListener<UploadBloc, UploadState>(
          listenWhen: (prev, curr) => prev.lastNotificationTime != curr.lastNotificationTime,
          listener: (context, state) {
            if (state.lastNotificationMessage != null) {
              
              // 1. Crear la notificación local
              final newNotification = LocalNotification(
                message: state.lastNotificationMessage!,
                timestamp: DateTime.now(),
                isRead: false, // Por defecto no leída
              );

              // 2. Agregarla a la lista y actualizar UI (contador sube)
              setState(() {
                _notifications.insert(0, newNotification);
              });
              
              // 3. Mostrar SnackBar
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Se ha terminado de procesar una imagen.'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 8),
                  action: SnackBarAction(
                    label: 'VER DETALLE',
                    textColor: AppColors.accent,
                    onPressed: () {
                      // 4. LÓGICA DE "MARCAR COMO LEÍDA" AL CLICAR
                      setState(() {
                        newNotification.isRead = true;
                        // El getter _unreadCount se actualizará automáticamente en el próximo build
                      });
                      
                      // 5. Navegar
                      _navigateToDetail();
                    },
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
                'Carga para Análisis',
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
                    // Usamos el getter dinámico
                    if (_unreadCount > 0)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$_unreadCount', // Muestra el conteo real
                            style: const TextStyle(
                              color: AppColors.primary,
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
                // Banner reconexión
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
                        const Text(
                          'Nuevo Análisis',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
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
                                    : AppColors.primary.withOpacity(0.2),
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
  
  // _buildLoadingView y _buildDropZoneView se mantienen iguales...
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
          child: const Icon(Icons.add_a_photo_outlined, size: 50, color: AppColors.primary),
        ),
        const SizedBox(height: 24),
        const Text('Seleccionar Imagen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: const Text('Formatos: JPG, PNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 50, height: 50, child: CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 4)),
        const SizedBox(height: 24),
        const Text('Subiendo imagen...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark)),
        const SizedBox(height: 8),
        Text('Preparando para análisis', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
      ],
    );
  }
}