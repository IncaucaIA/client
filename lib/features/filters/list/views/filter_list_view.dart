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
      create: (context) =>
          getIt<FilterListBloc>()..add(FilterListSubscriptionRequested()),
      child: const _FilterListScaffold(),
    );
  }
}

class _FilterListScaffold extends StatefulWidget {
  const _FilterListScaffold();

  @override
  State<_FilterListScaffold> createState() => _FilterListScaffoldState();
}

class _FilterListScaffoldState extends State<_FilterListScaffold> {
  // Local filter form values
  int? _selectedQuality;
  DateTime? _startDate;
  DateTime? _endDate;

  static const _qualityOptions = [1, 2, 3, 4, 5];

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _applyFilters(BuildContext context) {
    context.read<FilterListBloc>().add(FilterListFiltersApplied(
          quality: _selectedQuality,
          startDate: _startDate,
          endDate: _endDate,
        ));
    Navigator.pop(context);
  }

  void _clearFilters(BuildContext context) {
    setState(() {
      _selectedQuality = null;
      _startDate = null;
      _endDate = null;
    });
    context.read<FilterListBloc>().add(FilterListFiltersCleared());
    Navigator.pop(context);
  }

  void _showFilterSheet(BuildContext context) {
    // Sync local state with bloc state
    final blocState = context.read<FilterListBloc>().state;
    setState(() {
      _selectedQuality = blocState.quality;
      _startDate = blocState.startDate;
      _endDate = blocState.endDate;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<FilterListBloc>(),
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filtros',
                          style: Theme.of(sheetContext).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Quality filter
                  Text('Calidad',
                      style: Theme.of(sheetContext).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _qualityOptions.map((q) {
                      final selected = _selectedQuality == q;
                      return ChoiceChip(
                        label: Text('$q'),
                        selected: selected,
                        onSelected: (val) {
                          setSheetState(() {
                            _selectedQuality = val ? q : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Date range
                  Text('Rango de fechas',
                      style: Theme.of(sheetContext).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            _startDate != null
                                ? _formatDate(_startDate!)
                                : 'Fecha inicio',
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () async {
                            await _pickDate(context, isStart: true);
                            setSheetState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            _endDate != null
                                ? _formatDate(_endDate!)
                                : 'Fecha fin',
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () async {
                            await _pickDate(context, isStart: false);
                            setSheetState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _clearFilters(sheetContext),
                          child: const Text('Limpiar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _applyFilters(sheetContext),
                          child: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterListBloc, FilterListState>(
      builder: (context, state) {
        final hasActiveFilters =
            state.quality != null || state.startDate != null || state.endDate != null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Filtros'),
            actions: [
              // Filter button with badge when active
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    tooltip: 'Filtrar',
                    onPressed: () => _showFilterSheet(context),
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () =>
                    context.read<AuthBloc>().add(SignOutRequested()),
              ),
            ],
          ),
          body: Column(
            children: [
              // Active filters chips
              if (hasActiveFilters)
                _ActiveFiltersBar(state: state),

              // List
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (state.isLoading && state.filters.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.error != null && state.filters.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 8),
                            Text('Error: ${state.error}'),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => context
                                  .read<FilterListBloc>()
                                  .add(FilterListRefreshRequested()),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state.filters.isEmpty) {
                      return const Center(
                        child: Text('Sin resultados para los filtros aplicados.'),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => context
                          .read<FilterListBloc>()
                          .add(FilterListRefreshRequested()),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: state.filters.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 72),
                        itemBuilder: (context, index) {
                          final filter = state.filters[index];
                          return ListTile(
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.filter_alt,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer),
                            ),
                            title: Text('Filtro #${filter.id}'),
                            subtitle: Text(
                              'Impurezas: ${filter.impurityCount}  •  ${_formatDate(filter.processedAt)}',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FilterDetailView(detail: filter),
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

              // Pagination bar
              if (state.total > 0)
                _PaginationBar(state: state),
            ],
          ),
        );
      },
    );
  }
}

// ─── Active filters chips bar ────────────────────────────────────────────────

class _ActiveFiltersBar extends StatelessWidget {
  final FilterListState state;

  const _ActiveFiltersBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          if (state.quality != null)
            Chip(
              label: Text('Calidad: ${state.quality}'),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => context.read<FilterListBloc>().add(
                    FilterListFiltersApplied(
                      startDate: state.startDate,
                      endDate: state.endDate,
                    ),
                  ),
            ),
          if (state.startDate != null)
            Chip(
              label: Text(
                  'Desde: ${state.startDate!.day}/${state.startDate!.month}/${state.startDate!.year}'),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => context.read<FilterListBloc>().add(
                    FilterListFiltersApplied(
                      quality: state.quality,
                      endDate: state.endDate,
                    ),
                  ),
            ),
          if (state.endDate != null)
            Chip(
              label: Text(
                  'Hasta: ${state.endDate!.day}/${state.endDate!.month}/${state.endDate!.year}'),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => context.read<FilterListBloc>().add(
                    FilterListFiltersApplied(
                      quality: state.quality,
                      startDate: state.startDate,
                    ),
                  ),
            ),
        ],
      ),
    );
  }
}

// ─── Pagination bar ──────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  final FilterListState state;

  const _PaginationBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FilterListBloc>();
    final page = state.currentPage;
    final totalPages = state.totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous
          IconButton.outlined(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Anterior',
            onPressed: state.hasPreviousPage
                ? () => bloc.add(FilterListPageChanged(page - 1))
                : null,
          ),

          // Page indicator
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Página ${page + 1} de $totalPages',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${state.total} registros',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),

          // Next
          IconButton.outlined(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Siguiente',
            onPressed: state.hasNextPage
                ? () => bloc.add(FilterListPageChanged(page + 1))
                : null,
          ),
        ],
      ),
    );
  }
}
