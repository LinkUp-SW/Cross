import 'package:link_up/features/admin_panel/model/dashboard_model.dart';

class DashboardStates {}

class DashboardInitialState extends DashboardStates {}

class DashboardLoadingState extends DashboardStates {}

class DashboardErrorState extends DashboardStates {
  final String errorMessage;
  DashboardErrorState(this.errorMessage);
}

class DashboardSuccessState extends DashboardStates {}

class DashboardStatsCardData extends DashboardStates {
  List<StatCardsModel> statCardsData = [];
  DashboardStatsCardData(this.statCardsData);
  
}
