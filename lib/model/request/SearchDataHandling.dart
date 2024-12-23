class SearchDataHandling {
  final Map<String, dynamic> selectedSearchData; // Use dynamic for flexibility

  SearchDataHandling({required this.selectedSearchData});

  @override
  String toString() {
    return 'selectedSearchData: $selectedSearchData';
  }
}
