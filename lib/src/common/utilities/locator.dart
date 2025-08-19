import 'package:get_it/get_it.dart';
import 'package:micro_journal/src/common/common.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt
    ..registerLazySingleton(
      () => InternetCubit(),
    )
    ..registerLazySingleton(
      () => AuthRepository(
        userRepository: getIt<UserRepository>(),
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
      () => JournalRepository(),
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
