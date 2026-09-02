import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/notes_categories/notes_categories_cubit.dart';
import 'package:gep/cubits/notes_categories/notes_categories_state.dart';
import 'package:gep/router/app_navigation.dart';
import 'package:gep/router/app_routes.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:material_ui/material_ui.dart';

class AdminNotesCategoriesScreen extends StatefulWidget {
  const AdminNotesCategoriesScreen({super.key});

  @override
  State<AdminNotesCategoriesScreen> createState() =>
      _AdminNotesCategoriesScreenState();
}

class _AdminNotesCategoriesScreenState
    extends State<AdminNotesCategoriesScreen> {
  late final TextEditingController _categoryController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController();
    _searchController = TextEditingController();
    context.read<NotesCategoriesCubit>().fetchPage(0);
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleAddCategory() {
    final text = _categoryController.text.trim();
    if (text.isNotEmpty) {
      context.read<NotesCategoriesCubit>().addCategory(text);
      _categoryController.clear();
      FocusScope.of(context).unfocus();
    } else {
      TopSnackbar.info(context, 'Please enter a category name');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.darkScaffoldBackground
        : AppColors.lightScaffoldBackground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return AppScaffold(
      backgroundColor: backgroundColor,
      title: 'Categories',
      body: BlocConsumer<NotesCategoriesCubit, NotesCategoriesState>(
        listener: (context, state) {
          if (state.error != null && !state.isLoading && !state.isRefreshing) {
            TopSnackbar.error(context, state.error!);
          }
        },
        builder: (context, state) {
          final categories = state.items;
          final isLoading = state.isLoading && categories.isEmpty;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Top Creation Card
              SliverToBoxAdapter(
                child:
                    Container(
                          margin: const EdgeInsets.fromLTRB(
                            AppConstants.defaultPadding,
                            12,
                            AppConstants.defaultPadding,
                            16,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.2 : 0.03,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkNeutral
                                          : AppColors.lightNeutral,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.folder_rounded,
                                      size: 16,
                                      color: isDark
                                          ? AppColors.darkIcon
                                          : AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'CREATE CATEGORY',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      color: textColorSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TextFieldWidget(
                                      controller: _categoryController,
                                      labelText: 'Category Name',
                                      prefixIcon: Icons.folder_open_rounded,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    height: 45,
                                    width: 45,
                                    child: GestureDetector(
                                      onTap: _handleAddCategory,
                                      child: Material(
                                        borderRadius: BorderRadius.circular(16),
                                        color: AppColors.secondary,
                                        child: const Icon(
                                          Icons.add_rounded,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 200.ms)
                        .slideY(begin: -0.04, end: 0),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    0,
                    AppConstants.defaultPadding,
                    12,
                  ),
                  child: TextFieldWidget(
                    controller: _searchController,
                    labelText: 'Search categories',
                    hintText: 'Search categories…',
                    prefixIcon: Icons.search_rounded,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              context
                                  .read<NotesCategoriesCubit>()
                                  .clearSearch();
                            },
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: textColorSecondary,
                            ),
                          )
                        : null,
                    onChanged: (value) => context
                        .read<NotesCategoriesCubit>()
                        .setSearchQuery(value),
                  ),
                ),
              ),

              // Section Label with Dynamic Count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding + 4,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.folder_copy_rounded,
                            size: 14,
                            color: textColorSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'ALL CATEGORIES'
                                : 'SEARCH RESULTS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (!isLoading && categories.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkNeutral
                                : AppColors.lightNeutral,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${categories.length}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkBodyText
                                  : AppColors.lightBodyText,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Paginated View Handling
              if (isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: PlaceholderWidgets.listPlaceholder(),
                  ),
                )
              else if (state.error != null && categories.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load categories',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (categories.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkNeutral
                                : AppColors.lightNeutral,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.folder_off_rounded,
                            size: 36,
                            color: textColorSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Categories Found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.searchQuery.isEmpty
                              ? 'Add a new category above to get started'
                              : 'No matches for "${state.searchQuery}"',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: textColorSecondary,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final category = categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child:
                            Container(
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => AppNavigation.push(
                                        context,
                                        AppRoutes.kAddNotesRoute,
                                        extra: category,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? AppColors.darkNeutral
                                                    : AppColors.lightNeutral,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: Icon(
                                                Icons.folder_rounded,
                                                size: 22,
                                                color: isDark
                                                    ? AppColors.darkIcon
                                                    : AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Text(
                                                category,
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete_outline_rounded,
                                                color: AppColors.error
                                                    .withValues(alpha: 0.85),
                                                size: 20,
                                              ),
                                              onPressed: () => context
                                                  .read<NotesCategoriesCubit>()
                                                  .deleteCategory(category),
                                            ),
                                            const SizedBox(width: 2),
                                            Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 14,
                                              color: textColorSecondary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: (30 + index * 20).ms)
                                .slideY(begin: 0.05, end: 0),
                      );
                    }, childCount: categories.length),
                  ),
                ),

              // Pagination Controls
              if (categories.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.defaultPadding,
                      8,
                      AppConstants.defaultPadding,
                      4,
                    ),
                    child: PaginatedWidget(
                      isLoading: state.isLoading || state.isRefreshing,
                      hasPrevious: state.currentPage > 0,
                      hasNext: state.hasMore,
                      onPrevious: () =>
                          context.read<NotesCategoriesCubit>().previousPage(),
                      onNext: () =>
                          context.read<NotesCategoriesCubit>().nextPage(),
                      onPageSelected: (page) =>
                          context.read<NotesCategoriesCubit>().goToPage(page),
                      onRefresh: () =>
                          context.read<NotesCategoriesCubit>().refresh(),
                      currentPage: state.currentPage,
                      pageSize: 15,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}
