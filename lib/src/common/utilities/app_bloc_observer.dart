import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);

    if (bloc is Cubit) logman.info(change.toString());
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);

    logman.info(transition.toString());
  }
}
