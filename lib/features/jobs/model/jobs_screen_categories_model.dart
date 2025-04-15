class JobsCategoryModel {
  final String categoryName;
  final String categoryIcon;

  const JobsCategoryModel({
    required this.categoryName,
    required this.categoryIcon,
  });

  factory JobsCategoryModel.fromJson(Map<String, dynamic> json) {
    return JobsCategoryModel(
      categoryName: json['categoryName'],
      categoryIcon: json['categoryIcon'],
    );
  }

  static List<JobsCategoryModel> getAllCategories() {
    return [
      JobsCategoryModel(
        categoryName: 'Easy Apply',
        categoryIcon: 'assets/images/easyapply.png',
      ),
      JobsCategoryModel(
        categoryName: 'HR',
        categoryIcon: 'assets/images/HR.png',
      ),
      JobsCategoryModel(
        categoryName: 'Small biz',
        categoryIcon: 'assets/images/smallbiz.png',
      ),
      
    ];
  }
}