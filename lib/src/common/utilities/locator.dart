import 'package:get_it/get_it.dart';
import 'package:micro_journal/src/common/common.dart';

final getIt = GetIt.instance;

void setupLocator() {
  final notificationService = NotificationService.instance;
  getIt
    ..registerLazySingleton(
      () => InternetCubit(),
    )
    ..registerLazySingleton(
      () => AuthRepository(
        userRepository: getIt<UserRepository>(),
        notificationService: notificationService,
      ),
    )
    ..registerLazySingleton(
      () => UserRepository(),
    )
    ..registerLazySingleton(
      () => AuthCubit(authRepository: getIt<AuthRepository>()),
    )
    ..registerLazySingleton(
      () => UserProfileCubit(
        userRepository: getIt<UserRepository>(),
        authRepository: getIt<AuthRepository>(),
      ),
    )
    ..registerLazySingleton(
      () => JournalRepository(notificationService: notificationService),
    )
    ..registerLazySingleton(
      () => JournalCubit(getIt<JournalRepository>()),
    )
    ..registerLazySingleton(
      () => CommentsCubit(getIt<JournalRepository>()),
    )
    ..registerLazySingleton(
      () => JournalLikesCubit(getIt<JournalRepository>()),
    )
    ..registerLazySingleton(
      () => CalendarCubit(getIt<JournalRepository>()),
    )
    ..registerLazySingleton(
      () => CommentLikesCubit(getIt<JournalRepository>()),
    )
    ..registerLazySingleton(
      () => JournalStatsCubit(journalRepository: getIt<JournalRepository>()),
    );
}
