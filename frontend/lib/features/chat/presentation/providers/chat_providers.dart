import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/injection_container.dart';
import 'package:frontend/core/injection_container.dart' as di;
import 'package:frontend/features/chat/presentation/cubits/chat_cubit.dart';

List<BlocProvider> getChatProviders() {
  return [BlocProvider<ChatCubit>(create: (context) => di.getIt<ChatCubit>())];
}
