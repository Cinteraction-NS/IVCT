import 'package:cinteraction_vc/layers/data/dto/ai/ai_module_dto.dart';
import 'package:cinteraction_vc/layers/presentation/ui/profile/ui/widget/user_image.dart';

import '../../domain/entities/user.dart';
import 'chat/chat_detail_dto.dart';

import 'package:cinteraction_vc/layers/presentation/ui/profile/ui/widget/user_image.dart';

class UserDto extends User {
  final int? chatId;
  final List<ModuleDto> modules;

  UserDto({
    required super.id,
    required super.name,
    required super.email,
    required super.imageUrl,
    super.companyId,
    super.companyAdmin,
    this.chatId,
    this.modules = const [],
    super.online = false,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: "${json['id']}",
        name: json['name'] as String,
        email: json['email'] as String,
        imageUrl: json['profile_photo_path'] as String,
        chatId: json['chat_id'] as int?,
        companyId: json['company_id'] as int?,
        companyAdmin: json['company_admin'] as bool?,
        modules: (json['modules'] as List<dynamic>?)
                ?.map((e) => ModuleDto.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'email': email,
        'profile_photo_path': imageUrl,
        'chat_id': chatId,
        'company_id': companyId,
        'company_admin': companyAdmin,
        'modules': modules.map((m) => m.toJson()).toList(),
      };

  UserDto copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
    int? chatId,
    bool? online,
    int? companyId,
    bool? companyAdmin,
    List<ModuleDto>? modules,
  }) {
    return UserDto(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      chatId: chatId ?? this.chatId,
      online: online ?? this.online,
      companyId: companyId ?? this.companyId,
      companyAdmin: companyAdmin ?? this.companyAdmin,
      modules: modules ?? this.modules,
    );
  }

  @override
  UserImageDto getUserImageDTO() {
    return UserImageDto(id: int.parse(id), name: name, imageUrl: imageUrl);
  }
}

class UserListResponse {
  final List<UserDto> users;
  final PaginationLinks links;
  final PaginationMeta meta;

  UserListResponse({
    required this.users,
    required this.links,
    required this.meta,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      users: (json['data'] as List<dynamic>)
          .map((userJson) => UserDto.fromJson(userJson as Map<String, dynamic>))
          .toList(),
      links: PaginationLinks.fromJson(json['links'] as Map<String, dynamic>),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  PaginationLinks({
    required this.first,
    required this.last,
    required this.prev,
    required this.next,
  });

  factory PaginationLinks.fromJson(Map<String, dynamic> json) {
    return PaginationLinks(
      first: json['first'] as String?,
      last: json['last'] as String?,
      prev: json['prev'] as String?,
      next: json['next'] as String?,
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int from;
  final int lastPage;
  final String path;
  final int perPage;
  final int to;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int,
      from: json['from'] as int,
      lastPage: json['last_page'] as int,
      path: json['path'] as String,
      perPage: json['per_page'] as int,
      to: json['to'] as int,
      total: json['total'] as int,
    );
  }
}
