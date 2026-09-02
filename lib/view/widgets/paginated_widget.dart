import 'package:material_ui/material_ui.dart';

import '../../core/constants/constants.dart';

/// Professional pagination controls bar with numbered pages.
///
/// Shows Previous / Next navigation, clickable page numbers,
/// and an optional refresh action. Designed to sit at the bottom
/// of any paginated list.
///
/// For cursor pagination (no [totalPages]), the bar grows as the
/// user advances. Set [totalPages] when the total is known for
/// a bounded indicator.
class PaginatedWidget extends StatelessWidget {
  final bool isLoading;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int>? onPageSelected;
  final VoidCallback? onRefresh;
  final int currentPage;
  final int? totalPages;
  final int? totalCount;
  final int? pageSize;

  const PaginatedWidget({
    super.key,
    required this.isLoading,
    required this.hasPrevious,
    required this.hasNext,
    this.onPrevious,
    this.onNext,
    this.onPageSelected,
    this.onRefresh,
    required this.currentPage,
    this.totalPages,
    this.totalCount,
    this.pageSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final disabled = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;
    final active = isDark ? AppColors.darkBodyText : AppColors.lightBodyText;

    final startItem = totalCount != null && pageSize != null
        ? (currentPage * pageSize!) + 1
        : null;
    final endItem = totalCount != null && pageSize != null
        ? ((currentPage + 1) * pageSize!).clamp(0, totalCount!)
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: refresh, info, prev/next
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onRefresh != null)
                _IconBtn(
                  icon: Icons.refresh_rounded,
                  onTap: isLoading ? null : onRefresh,
                  color: isLoading ? disabled : active,
                )
              else
                const SizedBox(width: 40),
              Expanded(
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : Text(
                          startItem != null && endItem != null
                              ? '$startItem–$endItem of $totalCount'
                              : 'Page ${currentPage + 1}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: active,
                          ),
                        ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconBtn(
                    icon: Icons.chevron_left_rounded,
                    onTap: hasPrevious && !isLoading ? onPrevious : null,
                    color: hasPrevious && !isLoading ? active : disabled,
                  ),
                  const SizedBox(width: 8),
                  _IconBtn(
                    icon: Icons.chevron_right_rounded,
                    onTap: hasNext && !isLoading ? onNext : null,
                    color: hasNext && !isLoading ? active : disabled,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Page numbers row
          _PageNumbers(
            currentPage: currentPage,
            hasNext: hasNext,
            totalPages: totalPages,
            isLoading: isLoading,
            onPageSelected: onPageSelected,
          ),
        ],
      ),
    );
  }
}

class _PageNumbers extends StatelessWidget {
  final int currentPage;
  final bool hasNext;
  final int? totalPages;
  final bool isLoading;
  final ValueChanged<int>? onPageSelected;

  const _PageNumbers({
    required this.currentPage,
    required this.hasNext,
    this.totalPages,
    required this.isLoading,
    this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pages = _buildPageList();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: pages.map((p) {
        if (p == -1) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '…',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark
                    ? AppColors.darkBodyTextSecondary
                    : AppColors.lightBodyTextSecondary,
              ),
            ),
          );
        }

        final isCurrent = p == currentPage;
        final bg = isCurrent
            ? theme.colorScheme.primary
            : Colors.transparent;
        final fg = isCurrent
            ? theme.colorScheme.onPrimary
            : (isDark
                ? AppColors.darkBodyText
                : AppColors.lightBodyText);

        return Material(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: isLoading || isCurrent || onPageSelected == null
                ? null
                : () => onPageSelected!(p),
            child: Container(
              constraints: const BoxConstraints(minWidth: 32),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              alignment: Alignment.center,
              child: Text(
                '${p + 1}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<int> _buildPageList() {
    final pages = <int>[];
    final current = currentPage;
    final lastKnown = totalPages ?? (hasNext ? current + 2 : current);

    if (lastKnown <= 0) {
      pages.add(0);
      return pages;
    }

    // Always show page 1
    pages.add(0);

    // Window around current: current-1 to current+1
    final effectiveStart = (current - 1).clamp(1, lastKnown);
    final effectiveEnd = (current + 1).clamp(effectiveStart, lastKnown);

    if (effectiveStart > 1) pages.add(-1); // ellipsis before window
    for (int i = effectiveStart; i <= effectiveEnd; i++) {
      if (!pages.contains(i)) pages.add(i);
    }

    // Show one more page ahead if hasMore and no totalPages
    if (totalPages == null && hasNext && effectiveEnd + 1 <= lastKnown) {
      if (!pages.contains(effectiveEnd + 1)) pages.add(effectiveEnd + 1);
    }

    // Last page if total is known
    if (totalPages != null && totalPages! > 1) {
      if (!pages.contains(totalPages! - 1)) {
        if (pages.last < totalPages! - 2) pages.add(-1);
        pages.add(totalPages! - 1);
      }
    }

    return pages;
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  const _IconBtn({required this.icon, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 22, color: color),
        ),
      ),
    );
  }
}
