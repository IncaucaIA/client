import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/filter_detail_bloc.dart';
import '../bloc/filter_detail_state.dart';
import '../bloc/filter_detail_event.dart';
import 'package:incauca_labs/core/service_locator.dart';

class FilterDetailView extends StatelessWidget {
  final String filterId;

  const FilterDetailView({super.key, required this.filterId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FilterDetailBloc>()
        ..add(FilterDetailRequested(filterId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Detalle del Filtro')),
        body: BlocBuilder<FilterDetailBloc, FilterDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(child: Text('Error: ${state.error}'));
            }

            final result = state.detail;
            if (result == null) {
              return const Center(child: Text('No se encontró información.'));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen superior
                  Image.network(
                    result.imageUrl,
                    height: 380,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 380,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 80),
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
                        _buildRow("Primer Efecto", "${result.firstEffect}"),
                        _buildRow("Segundo Efecto", "${result.secondEffect}"),
                        _buildRow("Tercer Efecto", "${result.thirdEffect}"),
                        _buildRow("Cuarto Efecto", "${result.fourthEffect}"),
                        _buildRow("Quinto Efecto", "${result.fifthEffect}"),
                        const SizedBox(height: 30),
                        Text("Otros Resultados",
                            style: Theme.of(context).textTheme.headlineSmall),
                        const Divider(),
                        _buildRow("Otras", "${result.other}"),
                        _buildRow("Metal", "${result.metal}"),
                        _buildRow("Calidad", "${result.quality}"),
                        const SizedBox(height: 10),
                        _buildRow("Todos",
                            result.impurityCount.toString(),
                            isBold: true),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
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
