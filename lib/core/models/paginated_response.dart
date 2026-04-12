class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  bool get hasMore => currentPage < lastPage;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    // Handle cases where the whole object IS the response, or it's wrapped in 'data'
    // Some APIs return {"success": true, "data": {"data": [...], "current_page": 1}}
    // Others return {"data": [...], "meta": {...}}
    
    dynamic rawData = json['data'];
    Map<String, dynamic> meta = json;

    // If 'data' is a Map, it likely contains the list AND pagination info
    if (rawData is Map<String, dynamic>) {
      meta = rawData;
      rawData = rawData['data'];
    } 
    // If 'data' is null but the root has pagination info, the root is the meta
    else if (rawData == null && json['current_page'] != null) {
      rawData = json['data'] ?? []; // Should still be null or empty
    }

    final List<dynamic> list = rawData is List ? rawData : [];

    return PaginatedResponse(
      data: list.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      currentPage: int.tryParse(meta['current_page']?.toString() ?? '') ?? int.tryParse(meta['meta']?['current_page']?.toString() ?? '') ?? 1,
      lastPage: int.tryParse(meta['last_page']?.toString() ?? '') ?? int.tryParse(meta['meta']?['last_page']?.toString() ?? '') ?? 1,
      total: int.tryParse(meta['total']?.toString() ?? '') ?? int.tryParse(meta['meta']?['total']?.toString() ?? '') ?? list.length,
      perPage: int.tryParse(meta['per_page']?.toString() ?? '') ?? int.tryParse(meta['meta']?['per_page']?.toString() ?? '') ?? 15,
    );
  }
}
