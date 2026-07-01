import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/core/di/injection.dart';
import 'package:bazzone_driver/features/home/presentation/bloc/home_bloc.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'HomeRoute')
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(const HomeStarted()),
      child: const HomeView(),
    );
  }
}
