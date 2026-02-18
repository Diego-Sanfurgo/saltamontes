import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saltamontes/features/map_filter/bloc/map_filter_bloc.dart';

class MapFilterView extends StatelessWidget {
  const MapFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapFilterBloc(),
      child: _MapFilter(),
    );
  }
}

class _MapFilter extends StatelessWidget {
  const _MapFilter();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Filter')),
      body: _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        spacing: 16,
        children: [_TypeFilters(), _LocationFilters()],
      ),
    );
  }
}

class _TypeFilters extends StatelessWidget {
  const _TypeFilters();

  @override
  Widget build(BuildContext context) {
    return const Column(children: [Text('Tipos')]);
  }
}

class _LocationFilters extends StatelessWidget {
  const _LocationFilters();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
