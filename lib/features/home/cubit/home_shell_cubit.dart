import 'package:flutter_bloc/flutter_bloc.dart';

class HomeShellCubit extends Cubit<bool> {
  HomeShellCubit() : super(true);

  void showNavbar() => emit(true);

  void hideNavbar() => emit(false);

  void toggleNavbar() => emit(!state);
}
