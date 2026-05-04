import 'package:equatable/equatable.dart';

abstract class FilterDetailEvent extends Equatable {
  const FilterDetailEvent();

  @override
  List<Object?> get props => [];
}

class FilterDetailRequested extends FilterDetailEvent {
  final String filterId;

  const FilterDetailRequested(this.filterId);

  @override
  List<Object?> get props => [filterId];
}
