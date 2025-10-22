// ignore: depend_on_referenced_packages
import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> initializeApp() async {
    emit(SplashLoading());

    try {
      // Perform initialization tasks
      await Future.wait([
        // Add your initialization tasks here
        Future.delayed(const Duration(seconds: 1)), // Simulate loading
      ]);

      emit(SplashLoaded());
    } catch (e) {
      emit(SplashError(e.toString()));
    }
  }
}
