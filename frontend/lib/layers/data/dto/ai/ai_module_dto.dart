class ModuleDto {
  final int id;
  final String name;
  final String url;
  final int enabled;
  final int isGlobal;

  ModuleDto({
    required this.id,
    required this.name,
    required this.url,
    required this.enabled,
    required this.isGlobal,
  });

  factory ModuleDto.fromJson(Map<String, dynamic> json) {
    return ModuleDto(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      enabled: json['enabled'],
      isGlobal: json['is_global'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'enabled': enabled,
      'is_global': isGlobal,
    };
  }
}

class ModuleListResponse {
  final List<ModuleDto> modules;

  ModuleListResponse({required this.modules});

  factory ModuleListResponse.fromJson(Map<String, dynamic> json) {
    return ModuleListResponse(
      modules: (json['data'] as List<dynamic>)
          .map((e) => ModuleDto.fromJson(e))
          .toList(),
    );
  }
}
