import 'dart:async';

import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/core/io/network/models/login_response.dart';
import 'package:cinteraction_vc/layers/data/dto/ai/ai_module_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/api_error_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/engagement_dto.dart';
import 'package:cinteraction_vc/layers/domain/entities/meetings/meeting.dart';
import 'package:cinteraction_vc/layers/domain/entities/user.dart';
import 'package:cinteraction_vc/layers/domain/source/api.dart';
import 'package:cinteraction_vc/layers/presentation/ui/profile/ui/widget/user_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

import '../../../../core/io/network/urls.dart';
import '../../../../core/util/conf.dart';
import '../../../domain/entities/api_response.dart';
import '../../dto/chat/chat_dto.dart';
import '../../dto/dashboard/dashboard_response_dto.dart';
import '../../dto/meetings/meeting_dto.dart';
import '../../dto/meetings/meeting_response_dto.dart';

class ApiImpl extends Api {
  T? _parseResponseData<T>(
      dynamic data, T Function(Map<String, dynamic> json) fromJson) {
    return fromJson(data);
  }

  @override
  Future<ApiResponse<LoginResponse?>> signInEmailPass(
      {required email, required pass}) async {
    try {
      var formData = FormData.fromMap({'email': email, 'password': pass});
      Dio dio = await getIt.getAsync<Dio>();

      // clearDioCookies(dio);

      Response response = await dio.post(Urls.loginEndpoint, data: formData);
      LoginResponse? login =
          _parseResponseData(response.data, LoginResponse.fromJson);

      return ApiResponse(response: login);
      // return login;
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<UserDto?>> getUserDetails() async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.get(Urls.getUserDetails);
      print(response);
      return ApiResponse(
          response: _parseResponseData(response.data, UserDto.fromJson));
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<void>> createCompany({
    required int ownerId,
    required String name,
  }) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();

      final data = {
        "owner_id": ownerId,
        "name": name,
        "welcome_text": "Welcome to the company",
        "timetable_link": null,
      };

      final response = await dio.post(
        Urls.createCompany,
        data: data,
      );

      print('createCompany response: ${response.statusCode}');
      return ApiResponse(response: null);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<void>> deleteCompany({required companyId}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      await dio.delete('${Urls.deleteCompany} $companyId');
      return ApiResponse(response: null);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<void>> removeUserFromCompany(
      {required companyId, required userId}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      final response = await dio.post(
        '${baseUrl}/api/companies/$companyId/remove/$userId',
      );
      return ApiResponse(response: response);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<void>> inviteUserToCompany({
    required int companyId,
    required String email,
    required bool isAdmin,
  }) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();

      final data = {
        "company_id": companyId,
        "email": email,
        "company_admin": isAdmin,
      };

      final response = await dio.post(
        Urls.inviteUserToCompany,
        data: data,
        options: Options(
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        return ApiResponse(
          error: ApiErrorDto.fromDioResponse(response),
        );
      }

      return ApiResponse(response: null);
    } catch (e) {
      return ApiResponse(
        error: ApiErrorDto(
          errorCode: 0,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<ApiResponse<ModuleListResponse>> getCompanyModules(
      {required int companyId}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();

      Response response = await dio.get(
        '${Urls.getAllAiModules}$companyId',
      );

      var moduleListResponse = ModuleListResponse.fromJson(response.data);

      print('moduleListResponse: ${moduleListResponse.modules}');

      return ApiResponse(response: moduleListResponse);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ModuleListResponse>> updateModule({
    required int moduleId,
    required int companyId,
    required String aiModuleName,
    required String aiModuleUrl,
    required int enabled,
    required int isGlobal,
  }) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();

      final payload = {
        'company_id': companyId,
        'name': aiModuleName,
        'url': aiModuleUrl,
        'enabled': enabled,
      };

      final url = isGlobal == 1
          ? '${Urls.editGlobalModule}$moduleId'
          : '${Urls.editModule}$moduleId';

      final response = await dio.put(
        url,
        data: payload,
      );

      final moduleListResponse = ModuleListResponse.fromJson(response.data);

      return ApiResponse(response: moduleListResponse);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ModuleListResponse>> deleteAiModule({
    required int moduleId,
    required int companyId,
  }) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      final payload = {
        'company_id': companyId,
      };
      Response response = await dio.delete(
        '${Urls.deleteModule}$moduleId',
        data: payload,
      );
      final moduleListResponse = ModuleListResponse.fromJson(response.data);

      return ApiResponse(response: moduleListResponse);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ModuleListResponse>> addAiModule({
    required int companyId,
    required String aiModuleName,
    required String aiModuleUrl,
    required int enabled,
  }) async {
    try {
      final dio = await getIt.getAsync<Dio>();

      final payload = {
        'company_id': companyId,
        'name': aiModuleName,
        'url': aiModuleUrl,
        'enabled': enabled,
      };

      final response = await dio.post(
        Urls.createModule,
        data: payload,
      );

      final moduleListResponse = ModuleListResponse.fromJson(response.data);

      return ApiResponse(response: moduleListResponse);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<UserListResponse>> getCompanyUsers(
    int page,
    int paginate,
    int companyId,
    String? search,
  ) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();

      final queryParams = <String, dynamic>{
        if (search == null || search.isEmpty) ...{
          'page': page.toString(),
          'paginate': paginate.toString(),
        },
        if (search != null && search.isNotEmpty) 'search': search,
      };

      Response response = await dio.get(
        '${Urls.getCompanyUsers}/$companyId/users',
        queryParameters: queryParams,
      );

      var userListResponse = UserListResponse.fromJson(response.data);

      print('usersListResponse: ${userListResponse.users}');

      return ApiResponse(response: userListResponse);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<String?> socialLogin({required provider, required token}) async {
    Dio dio = await getIt.getAsync<Dio>();

    var formData = FormData.fromMap({'provider': provider, 'token': token});
    Response response =
        await dio.post(Urls.socialLoginEndpoint, data: formData);
    var accessToken = response.data['access_token'] as String;

    return accessToken;
  }

  @override
  Future<({double score, String name})?> getModuleScore({
    required String url,
    required String name,
    required int callId,
    required String image,
    required String participantId,
  }) async {
    final formData = {
      'call_id': callId,
      'image': image,
      'participant_id': participantId,
    };

    final Dio dio = await getIt.getAsync<Dio>();
    try {
      final response = await dio.post(url, data: formData);

      final responseData = response.data;
      if (responseData is Map && responseData.isNotEmpty) {
        final firstKey = responseData.keys.first;
        final score = responseData[firstKey]?[0]?['score'];

        if (score != null) {
          print('module: $name, score: $score');
          return (
            score: double.parse(score.toString()),
            name: name.toLowerCase(),
          );
        }
      }
    } catch (e) {
      print('getModuleScore error: $e');
    }

    return null;
  }

  @override
  Future<ApiResponse<MeetingDto>> startCall(
      {required streamId, required userId}) async {
    Dio dio = await getIt.getAsync<Dio>();
    print('UserId: $userId');
    try {
      var formData = {
        'stream_id': streamId,
        'user_id': int.parse(userId),
        'timezone': 'Europe/Belgrade',
        'recording': false
      };

      print(formData);
      Response response = await dio.post(Urls.startCall, data: formData);
      var callId = response.data['meeting_id'] as int;
      var chatId = response.data['chat_id'] as int;
      print('callId $callId');

      MeetingDto meetingDto = new MeetingDto(
          callId: callId,
          chatId: chatId,
          organizerId: 0,
          organizer: "",
          meetingStart:
              DateTime.parse(response.data['meeting_start'] as String));

      return ApiResponse(response: meetingDto);
      // return login;
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<bool> endCall({required callId, required userId}) async {
    Dio dio = await getIt.getAsync<Dio>();
    var userIds = int.parse(userId);
    var formData = FormData.fromMap({
      'meeting_id': callId,
      'user_id': userIds,
    });
    Response response = await dio.post(
      Urls.endCall(callId, userIds),
      data: formData,
    );
    print('end call by user $response');

    return response.statusCode == 200;
  }

  @override
  Future<ApiResponse<MeetingResponseDto>> getMeetings(int page) async {
    Dio dio = await getIt.getAsync<Dio>();
    try {
      Response response = await dio.get('${Urls.meetings}$page');

      List<MeetingDto> meetings = [];

      for (var par in response.data['data']) {
        var participant = MeetingDto.fromJson(par as Map<String, dynamic>);
        meetings.add(participant);
      }

      // var lastPage = response.data['last_page'];

      return ApiResponse(response: MeetingResponseDto.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<List<MeetingDto>?>> getScheduledMeetings() async {
    Dio dio = await getIt.getAsync<Dio>();
    try {
      Response response = await dio.get(Urls.scheduledMeetings);
      List<MeetingDto> meetings = [];
      for (var meet in response.data['data']) {
        var meeting = MeetingDto.fromJson(meet as Map<String, dynamic>);
        meetings.add(meeting);
      }
      return ApiResponse(response: meetings);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<MeetingDto?>> getNextMeeting() async {
    Dio dio = await getIt.getAsync<Dio>();
    try {
      Response response = await dio.get(Urls.nextScheduledMeetings);
      MeetingDto? nextMeeting;
      final now = DateTime.now();

      final allMeetings = (response.data['data'] as List)
          .map((meet) => MeetingDto.fromJson(meet as Map<String, dynamic>))
          .toList();

      final futureMeetings = allMeetings
          .where((meeting) => meeting.meetingEnd!.isAfter(now))
          .toList();

      futureMeetings.sort((a, b) => a.meetingStart.compareTo(b.meetingStart));

      if (futureMeetings.isNotEmpty) {
        nextMeeting = futureMeetings.first;
      }

      return ApiResponse(response: nextMeeting);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<String>> signUpEmailPass(
      {required email, required pass, required name, required terms}) async {
    Dio dio = await getIt.getAsync<Dio>();

    var formData = {
      'name': name,
      'email': email,
      'password': pass,
      'password_confirmation': pass,
      // 'terms': terms
    };

    try {
      Response response = await dio.post(Urls.registerEndpoint, data: formData);
      return ApiResponse(response: response.data["message"]);
    } on DioException catch (e, s) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<Meeting?>> scheduleMeeting(
      {required String name,
      required String description,
      required String tag,
      required DateTime date,
      required List<String> emails}) async {
    Dio dio = await getIt.getAsync<Dio>();

    var formData = {
      'event_name': name,
      'event_description': description,
      // 'tag': tag,
      'startDateTime': DateFormat('yyyy-MM-dd HH:mm').format(date),
      'timezone': 'Europe/Belgrade',
      'participants_emails': emails
    };

    print(DateFormat('yyyy-MM-dd HH:mm').format(date));

    try {
      Response response = await dio.post(Urls.scheduleMeeting, data: formData);
      print(response);
      return ApiResponse(response: Meeting.fromJson(response.data));
    } on DioException catch (e, s) {
      print(e.response?.statusMessage);
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<bool>> sendEngagement(
      {required engagement, required userId, required callId}) async {
    Dio dio = await getIt.getAsync<Dio>();

    var formData = {
      'attention': engagement,
      // 'user_id': userId,
      // 'call_id': callId,
    };

    try {
      Response response =
          await dio.post('${Urls.sendEngagement}$callId', data: formData);
      // print(response);
      return ApiResponse(
          response: response.statusCode! > 200 && response.statusCode! < 300);
    } on DioException catch (e, s) {
      print(e.response?.statusMessage);
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<bool?>> sendMessage(
      {required String userId,
      required String message,
      required String callId}) {
    // TODO: implement sendMessage
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<DashboardResponseDto?>> getDashboardData() async {
    Dio dio = await getIt.getAsync<Dio>();

    try {
      Response response = await dio.get(Urls.dashboard);
      // print(response.data);
      var dashboard =
          DashboardResponseDto.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(response: dashboard);
    } on DioException catch (e, s) {
      print(e.response?.statusMessage);
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<bool>> resetPassword({required email}) async {
    // https://vc.cinteraction.com/api/forgot-password
    // Method: POST
    // Header:
    // Accept: application/json
    // Body:
    // email

    Dio dio = await getIt.getAsync<Dio>();
    var formData = {
      'email': email,
    };
    try {
      Response response = await dio.post(Urls.restPassword, data: formData);
      print(response);
      return ApiResponse(
          response: response.statusCode! > 200 && response.statusCode! < 300);
    } on DioException catch (e, s) {
      print(e.response?.statusMessage);
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<bool>> setNewPassword(
      {required email, required token, required newPassword}) async {
    Dio dio = await getIt.getAsync<Dio>();

    var formData = {
      'email': email,
      'token': token,
      'password': newPassword,
      'password_confirmation': newPassword
    };
    try {
      Response response = await dio.post(Urls.setNewPassword, data: formData);
      print(response);
      return ApiResponse(
          response: response.statusCode! > 200 && response.statusCode! < 300);
    } on DioException catch (e, s) {
      print(e.response?.statusMessage);
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<bool>> sentChatMessage(
      {required text, required from, required to}) async {
    Dio dio = await getIt.getAsync<Dio>();
    var formData = {'text': text, 'from': from, 'to': to};
    try {
      Response response = await dio.post(Urls.sentMessage, data: formData);
      print("ChatMessageToServer $response");
      return ApiResponse(
          response: response.statusCode! > 200 && response.statusCode! < 300);
    } on DioException catch (e, s) {
      print(e.response?.statusMessage);
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatPagination>> getAllChats({
    required int page,
    required int paginate,
    String? search,
  }) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      print('SEARCH $search');
      final queryParams = <String, dynamic>{
        if (search == null || search.isEmpty) ...{
          'page': page.toString(),
          'paginate': paginate.toString(),
        },
        if (search != null && search.isNotEmpty) 'search': search,
      };

      Response response = await dio.get(
        Urls.getAllChats,
        queryParameters: queryParams,
      );
      print('response: ${response.data}');
      ChatPagination chatPagination =
          ChatPagination.fromJson(response.data as Map<String, dynamic>);

      return ApiResponse(response: chatPagination);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<List<ChatDto>>> deleteChat({
    required int chatId,
    required int userId,
  }) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();

      Response response = await dio.post(
        '${Urls.deleteChat}$chatId/$userId',
      );

      List<ChatDto> chats = [];
      for (var chat in response.data['data']) {
        var chatDto = ChatDto.fromJson(chat as Map<String, dynamic>);
        chats.add(chatDto);
      }

      return ApiResponse(response: chats);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatDetailsDto>> getChatById(
      {required id, required page}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.get('${Urls.getChatById}$id?page=$page');
      var chatDetails = ChatDetailsDto.fromJson(response.data);

      return ApiResponse(response: chatDetails);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<Uint8List>> downloadMedia({required int id}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response<List<int>> response = await dio.get<List<int>>(
        '${Urls.downloadMedia}$id',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      print('ResponseMedia: $response');

      if (response.data == null) {
        print('There is no file!');
      }

      return ApiResponse(response: Uint8List.fromList(response.data!));
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatDetailsDto>> getChat() async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.get(Urls.getChatById);
      var chatDetails = ChatDetailsDto.fromJson(response.data);

      return ApiResponse(response: chatDetails);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatDetailsDto>> getChatByParticipiant(
      {required int id, required int page}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response =
          await dio.get('${Urls.getChatByParticipiant}$id?page=$page');
      var chatDetails = ChatDetailsDto.fromJson(response.data);

      return ApiResponse(response: chatDetails);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatDetailsDto>> addUserToGroupChat({
    required int chatId,
    required int userId,
    required List<int> participantIds,
  }) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.post(
        "${Urls.addUserOnGroupChat}$chatId",
        data: {
          "chat_participants":
              participantIds.map((id) => {"participant_id": id}).toList(),
          "user_id": userId,
        },
      );
      var chatDetails = ChatDetailsDto.fromJson(response.data);

      return ApiResponse(response: chatDetails);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatDetailsDto>> removeUserFromGroupChat(
      {required int chatId, required int userId}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.post(
        "${Urls.removeUserFromGroupChat}$chatId",
        data: {"user_id": userId},
      );
      var chatDetails = ChatDetailsDto.fromJson(response.data);

      return ApiResponse(response: chatDetails);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatDetailsDto>> deleteMessageById(
      {required dynamic id}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.delete('${Urls.deleteMessageById}$id');
      var chatDetails = ChatDetailsDto.fromJson(response.data);
      return ApiResponse(response: chatDetails);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatDetailsDto>> editMessageById({
    required int id,
    required String message,
  }) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.put(
        '${Urls.editMessage}$id',
        data: {
          'message': message,
        },
      );
      var chatDetails = ChatDetailsDto.fromJson(response.data);
      return ApiResponse(response: chatDetails);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<UserDto>> changeProfileImage({
    required PlatformFile file,
    required User user,
  }) async {
    Dio dio = await getIt.getAsync<Dio>();

    final formData = FormData();

    if (file.bytes != null) {
      formData.files.add(
        MapEntry(
          'image',
          MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ),
        ),
      );
    } else if (file.path != null) {
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
          ),
        ),
      );
    } else {
      return ApiResponse(
        error: ApiErrorDto(errorCode: 400, errorMessage: 'There is error'),
      );
    }

    try {
      final response = await dio.post(
        Urls.userImage,
        data: formData,
        options: Options(headers: {
          Headers.contentTypeHeader: 'multipart/form-data',
        }),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final String imageUrl = response.data['url'] ?? '';

        final userDetailsResponse = await getUserDetails();

        if (userDetailsResponse.response != null) {
          final updatedUser = userDetailsResponse.response!;
          // final newUser = updatedUser.copyWith(imageUrl: imageUrl);
          return ApiResponse(
              response: UserDto(
                  id: user.id,
                  name: user.name,
                  email: user.id,
                  imageUrl: imageUrl));
        } else {
          return ApiResponse(
            error: ApiErrorDto(errorMessage: 'Not works', errorCode: 400),
          );
        }
      } else {
        return ApiResponse(
          error:
              ApiErrorDto(errorMessage: 'Unexpected response', errorCode: 400),
        );
      }
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<UserDto>> updateUserProfile({
    PlatformFile? file,
    required User user,
    String? name,
    String? email,
    String? password,
    String? passwordConfirmation,
  }) async {
    final Dio dio = await getIt.getAsync<Dio>();

    final formData = FormData.fromMap({
      'name': name,
      'email': email,
      '_method': 'PUT',
      if (password != null && password.isNotEmpty) ...{
        'password': password,
        'password_confirmation': password,
      }
    });

    if (file?.bytes != null) {
      formData.files.add(
        MapEntry(
          'image',
          MultipartFile.fromBytes(
            file!.bytes!,
            filename: file.name,
          ),
        ),
      );
    } else if (file?.path != null) {
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            file!.path!,
            filename: file.name,
          ),
        ),
      );
    }

    try {
      final response = await dio.post(
        Urls.updateUser(user.id),
        data: formData,
        options: Options(
          headers: {
            Headers.contentTypeHeader: 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final userDetailsResponse = await getUserDetails();

        if (userDetailsResponse.response != null) {
          return ApiResponse(response: userDetailsResponse.response!);
        } else {
          return ApiResponse(
            error:
                ApiErrorDto(errorMessage: 'Here is the error', errorCode: 400),
          );
        }
      } else {
        return ApiResponse(
          error: ApiErrorDto(errorMessage: 'Here is the error', errorCode: 400),
        );
      }
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<MessageDto>> sendMessageToChat({
    String? name,
    int? chatId,
    required int senderId,
    String? message,
    required List<int> participantIds,
    List<PlatformFile>? uploadedFiles,
    void Function(double progress)? onProgress,
  }) async {
    Dio dio = await getIt.getAsync<Dio>();

    print('Name $name');

    var formDataMap = {
      'sender_id': senderId,
      'chat_participants':
          participantIds.map((id) => {'participant_id': id}).toList(),
    };

    if (chatId != null) {
      formDataMap['chat_id'] = chatId;
    }

    if (name != null) {
      formDataMap['name'] = name;
    }

    if (message != null && message.trim().isNotEmpty) {
      formDataMap['message'] = message;
    }
    if (uploadedFiles != null && uploadedFiles.isNotEmpty) {
      List<MultipartFile> files = [];

      for (var file in uploadedFiles) {
        if (file.bytes != null) {
          files.add(
            MultipartFile.fromBytes(
              file.bytes!,
              filename: file.name,
            ),
          );
        }
      }

      formDataMap['uploaded_files'] = files;
    }

    var formData = FormData.fromMap(formDataMap);

    try {
      Response response;

      if (uploadedFiles != null && uploadedFiles.isNotEmpty) {
        response = await dio.post(
          options: Options(headers: {
            Headers.contentTypeHeader: 'multipart/form-data',
          }),
          Urls.sentChatMessage,
          data: formData,
          onSendProgress: (int sent, int total) {
            double progress = sent / total;
            print("Progress fajlova: ${(progress * 100).toStringAsFixed(0)}%");
            if (onProgress != null) {
              onProgress(progress);
            }
          },
        );
      } else {
        response = await dio.post(
          Urls.sentChatMessage,
          data: formData,
        );
      }

      if (response.data != null &&
          response.data['messages'] is Map<String, dynamic>) {
        final messagesMap = response.data['messages'] as Map<String, dynamic>;

        if (messagesMap.containsKey('data') && messagesMap['data'] is List) {
          final List<MessageDto> parsedMessages = (messagesMap['data']
                  as List<dynamic>)
              .map((msg) => MessageDto.fromJson(msg as Map<String, dynamic>))
              .toList();
          if (parsedMessages.isNotEmpty) {
            return ApiResponse(response: parsedMessages.first);
          }
        }
      }
      var messageDto = MessageDto.fromJson(response.data);
      return ApiResponse(response: messageDto);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<EngagementResponseDto>> createEngagement({
    required int meetingId,
    required int userId,
    required int moduleId,
    required double value,
  }) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();

      final data = {
        'meeting_id': meetingId,
        'user_id': userId,
        'module_id': moduleId,
        'value': value,
      };

      final response = await dio.post(
        '${baseUrl}/api/engagement/create',
        data: data,
      );

      print('createEngagement response: ${response.statusCode}');

      final engagementResponse = EngagementResponseDto.fromJson(response.data);
      return ApiResponse(response: engagementResponse);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<EngagementTotalAverageDto>> getEngagementTotalAverage({
    required int meetingId,
    required int moduleId,
  }) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();

      final response = await dio.get(
        Urls.getEngagementTotalAverage(meetingId),
      );

      print('getEngagementTotalAverage response: ${response.statusCode}');
      print('getEngagementTotalAverage data: ${response.data}');

      final engagementData = EngagementTotalAverageDto.fromJson(response.data);
      return ApiResponse(response: engagementData);
    } on DioException catch (e) {
      print('❌ getEngagementTotalAverage error: ${e.response?.data}');
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }
}
