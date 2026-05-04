import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incauca_labs/core/service_locator.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_bloc.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_event.dart';
import 'package:incauca_labs/features/filters/detail/views/filter_detail_view.dart';
import '../bloc/filter_list_bloc.dart';
import '../bloc/filter_list_event.dart';
import '../bloc/filter_list_state.dart';

class FilterListView extends StatelessWidget {
  const FilterListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FilterListBloc>()
        ..add(FilterListSubscriptionRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Filtros'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
            ),
          ],
        ),
        body: BlocBuilder<FilterListBloc, FilterListState>(
          builder: (context, state) {
            if (state.isLoading && state.filters.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null && state.filters.isEmpty) {
              return Center(child: Text('Error: ${state.error}'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FilterListBloc>().add(FilterListRefreshRequested());
              },
              child: ListView.builder(
                itemCount: state.filters.length,
                itemBuilder: (context, index) {
                  final filter = state.filters[index];
                  return ListTile(
                    leading: const Icon(Icons.filter_alt),
                    title: Text('Filtro ${filter.id}'),
                    subtitle: Text('Impurezas: ${filter.impurityCount}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilterDetailView(filterId: filter.id),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
