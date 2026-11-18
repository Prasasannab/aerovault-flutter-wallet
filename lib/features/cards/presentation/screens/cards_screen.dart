import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/cards_bloc.dart';
import '../bloc/cards_event.dart';
import '../bloc/cards_state.dart';
import '../widgets/card_security_switches_widget.dart';
import '../widgets/card_spending_slider_widget.dart';
import '../widgets/card_visual_widget.dart';
import '../widgets/new_card_sheet.dart';
import '../widgets/sensitive_card_details_widget.dart';

class CardsScreen extends StatelessWidget {
  final bool isStandalone;
  final ScrollController? scrollController;

  const CardsScreen({
    super.key,
    this.isStandalone = false,
    this.scrollController,
  });

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CardsScreen(isStandalone: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CardsBloc>(
      create: (_) => sl<CardsBloc>()..add(const LoadCardsEvent()),
      child: _CardsScreenContent(
        isStandalone: isStandalone,
        scrollController: scrollController,
      ),
    );
  }
}

class _CardsScreenContent extends StatefulWidget {
  final bool isStandalone;
  final ScrollController? scrollController;

  const _CardsScreenContent({
    required this.isStandalone,
    this.scrollController,
  });

  @override
  State<_CardsScreenContent> createState() => _CardsScreenContentState();
}

class _CardsScreenContentState extends State<_CardsScreenContent> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.90);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showNewCardSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    NewCardSheet.show(
      context,
      onCardCreated: (name, type, limit) {
        context.read<CardsBloc>().add(
              IssueNewCardEvent(name: name, type: type, limit: limit),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: context.colors.surfaceElevated,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text(
              'New card "$name" successfully provisioned and ready for use.',
              style: AppTextStyles.bodySmall(color: context.colors.textPrimary),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<CardsBloc, CardsState>(
          listener: (context, state) {
            if (state is CardsLoaded) {
              if (_pageController.hasClients &&
                  _pageController.page?.round() != state.selectedIndex) {
                _pageController.animateToPage(
                  state.selectedIndex,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                );
              }
            }
          },
          builder: (context, state) {
            if (state is CardsLoading || state is CardsInitial) {
              return Center(
                child: CircularProgressIndicator(color: colors.primary),
              );
            }

            if (state is CardsError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 36),
                    const SizedBox(height: 12),
                    Text(state.message, style: AppTextStyles.bodyMedium(color: colors.textPrimary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<CardsBloc>().add(const LoadCardsEvent()),
                      child: const Text('RETRY'),
                    ),
                  ],
                ),
              );
            }

            final loaded = state as CardsLoaded;
            final cards = loaded.cards;
            final activeCard = loaded.activeCard;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CardsBloc>().add(const LoadCardsEvent());
              },
              color: colors.primary,
              backgroundColor: colors.surfaceElevated,
              child: SingleChildScrollView(
                controller: widget.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (widget.isStandalone)
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 20),
                              ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cards Studio',
                                  style: AppTextStyles.heading1(color: colors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Multi-tier digital & metal payment cards',
                                  style: AppTextStyles.bodySmall(color: colors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showNewCardSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary.withValues(alpha: 0.15),
                            foregroundColor: colors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('NEW CARD'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Multi-Card Horizontal PageView Carousel
                    SizedBox(
                      height: 236,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: cards.length,
                        onPageChanged: (index) {
                          HapticFeedback.selectionClick();
                          context.read<CardsBloc>().add(SelectCardIndexEvent(index));
                        },
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return CardVisualWidget(card: card);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Page Indicator Dots
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(cards.length, (index) {
                          final isSelected = index == loaded.selectedIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: isSelected ? 24 : 6,
                            decoration: BoxDecoration(
                              color: isSelected ? colors.primary : colors.border,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: colors.primaryGlow,
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sensitive Credentials Shield
                    SensitiveCardDetailsWidget(
                      card: activeCard,
                      onToggleReveal: () {
                        context.read<CardsBloc>().add(
                              RevealCardDetailsEvent(cardId: activeCard.id),
                            );
                      },
                    ),
                    const SizedBox(height: 18),

                    // Monthly Spending Limit Slider
                    CardSpendingSliderWidget(
                      card: activeCard,
                      onLimitChanged: (newLimit) {
                        context.read<CardsBloc>().add(
                              UpdateCardLimitEvent(
                                cardId: activeCard.id,
                                limit: newLimit,
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 18),

                    // Security & Channel Switches
                    CardSecuritySwitchesWidget(
                      card: activeCard,
                      onToggleFreeze: (freeze) {
                        context.read<CardsBloc>().add(
                              ToggleFreezeCardEvent(
                                cardId: activeCard.id,
                                freeze: freeze,
                              ),
                            );
                      },
                      onToggleChannel: (channel, isEnabled) {
                        context.read<CardsBloc>().add(
                              ToggleCardChannelEvent(
                                cardId: activeCard.id,
                                channel: channel,
                                isEnabled: isEnabled,
                              ),
                            );
                      },
                      onRegenerateDisposable: () {
                        context.read<CardsBloc>().add(
                              RegenerateDisposableCardEvent(cardId: activeCard.id),
                            );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
