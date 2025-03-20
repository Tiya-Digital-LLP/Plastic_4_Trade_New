class SearchImageWebModel {
  final String title;
  final String link;
  final String image;

  SearchImageWebModel(
      {required this.title, required this.link, required this.image});

  factory SearchImageWebModel.fromJson(Map<String, dynamic> json) {
    return SearchImageWebModel(
      title: json['title']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }
}
