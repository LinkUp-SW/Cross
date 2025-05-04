import 'package:flutter/widgets.dart';

class StatCardsModel {
  String? title;
  String? value;
  int? changeText;
  Color? changeColor;
  StatCardsModel({
    this.title,
    this.value,
    this.changeText,
    this.changeColor,
  });
  StatCardsModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = json['value'];
    changeText = json['changeText'];
    changeColor = json['changeColor'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['value'] = value;
    data['changeText'] = changeText;
    data['changeColor'] = changeColor;
    return data;
  }
}

class DashboardCardModel {}
