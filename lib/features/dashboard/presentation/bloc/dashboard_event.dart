import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  final String? dateFilter;

  const LoadDashboardData({this.dateFilter});

  @override
  List<Object?> get props => [dateFilter];
}

class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();
}

class UpdateDateFilter extends DashboardEvent {
  final String dateFilter;

  const UpdateDateFilter(this.dateFilter);

  @override
  List<Object?> get props => [dateFilter];
}
