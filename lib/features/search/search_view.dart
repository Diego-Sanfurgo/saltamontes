import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saltamontes/core/services/navigation_service.dart';

import 'package:saltamontes/data/providers/place_provider.dart';
import 'package:saltamontes/data/repositories/place_repository.dart';
import 'package:saltamontes/features/search/widgets/result_list.dart';
import 'package:saltamontes/widgets/animated_search_text.dart';

import 'cubit/search_bar_cubit.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => PlaceRepository(PlaceApiProvider()),
      child: BlocProvider(
        create: (context) => SearchBarCubit(context.read<PlaceRepository>()),
        child: _SearchViewWidget(),
      ),
    );
  }
}

class _SearchViewWidget extends StatefulWidget {
  const _SearchViewWidget();

  @override
  State<_SearchViewWidget> createState() => _SearchViewWidgetState();
}

class _SearchViewWidgetState extends State<_SearchViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _Body()));
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverAppBar(
            leading: IconButton(
              icon: Icon(BootstrapIcons.arrow_left),
              onPressed: () => NavigationService.pop(),
            ),
            actions: [
              IconButton(
                onPressed: () => NavigationService.push(Routes.MAP_FILTER),
                icon: Icon(BootstrapIcons.sliders, size: 18),
              ),
            ],
            titleSpacing: 0,
            title: _SearchBarWidget(),
            pinned: true,
            // floating: true,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.green),
              borderRadius: BorderRadiusGeometry.circular(30),
            ),
          ),
        ),

        BlocBuilder<SearchBarCubit, SearchBarState>(
          builder: (context, state) {
            return switch (state.status) {
              SearchBarStatus.initial => SliverFillRemaining(
                child: Center(child: Text('Buscá una montaña, lago o sendero')),
              ),
              SearchBarStatus.loading => SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              SearchBarStatus.failure => SliverFillRemaining(
                child: Center(
                  child: Text('No encontré nada, ¿probás con otro?'),
                ),
              ),
              SearchBarStatus.success =>
                state.places.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Text('No encontré nada, ¿probás con otro?'),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: ResultList(places: state.places),
                      ),
            };
          },
        ),
      ],
    );
  }
}

class _SearchBarWidget extends StatefulWidget {
  const _SearchBarWidget();

  @override
  State<_SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<_SearchBarWidget> {
  late final TextEditingController _controller;
  late final SearchBarCubit _cubit;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _cubit = BlocProvider.of<SearchBarCubit>(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: TextFormField(
        autofocus: true,
        decoration: InputDecoration(
          hint: AnimatedSearchText(),
          border: InputBorder.none,
        ),
        controller: _controller,
        onChanged: (value) => _cubit.queryPeaks(value),
        // elevation: WidgetStateProperty.all(0),
      ),
    );
  }
}
