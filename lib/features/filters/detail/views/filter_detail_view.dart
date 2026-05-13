import 'package:flutter/material.dart';
import 'package:incauca_labs/features/filters/domain/models/filter_detail.dart';

class FilterDetailView extends StatelessWidget {
  final FilterDetail detail;

  const FilterDetailView({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Filtro')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen superior
            GestureDetector(
              onTap: () => _showFullScreenImage(context),
              child: Hero(
                tag: 'image_${detail.id}',
                child: Image.network(
                  detail.imageUrl,
                  height: 380,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 380,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, size: 80),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sección Efectos",
                      style: Theme.of(context).textTheme.headlineSmall),
                  const Divider(),
                  _buildRow("Primer Efecto", "${detail.firstEffect}"),
                  _buildRow("Segundo y Tercer Efecto", "${detail.secondAndThirdEffect}"),
                  _buildRow("Cuarto Efecto", "${detail.fourthEffect}"),
                  _buildRow("Quinto Efecto", "${detail.fifthEffect}"),
                  const SizedBox(height: 30),
                  Text("Otros Resultados",
                      style: Theme.of(context).textTheme.headlineSmall),
                  const Divider(),
                  _buildRow("Otras", "${detail.other}"),
                  _buildRow("Metal", "${detail.metal}"),
                  const SizedBox(height: 10),
                  _buildRow("Todos",
                      detail.impurityCount.toString(),
                      isBold: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        extendBodyBehindAppBar: true,
        body: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Hero(
              tag: 'image_${detail.id}',
              child: Image.network(
                detail.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
