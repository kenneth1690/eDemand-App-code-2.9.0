import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUsersScreen extends StatefulWidget {
  const ChatUsersScreen({
    super.key,
  });

  @override
  State<ChatUsersScreen> createState() => _ChatUsersScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => const ChatUsersScreen(),
    );
  }
}

class _ChatUsersScreenState extends State<ChatUsersScreen> {
  late final ScrollController _scrollController = ScrollController()
    ..addListener(_chatUserScrollListener);

  void _chatUserScrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
      if (context.read<ChatUsersCubit>().hasMore()) {
        context.read<ChatUsersCubit>().fetchMoreChatUsers();
      }
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      fetchChatUsers();
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_chatUserScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void fetchChatUsers() {
    context.read<ChatUsersCubit>().fetchChatUsers();
  }

  Widget _buildShimmerLoader() {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return SizedBox(
          height: double.maxFinite,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: UiUtils.numberOfShimmerContainer,
            itemBuilder: (context, index) {
              return _buildOneChatUserShimmerLoader();
            },
          ),
        );
      },
    );
  }

  Widget _buildOneChatUserShimmerLoader() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: CustomShimmerLoadingContainer(
        height: 80,
        borderRadius: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InterstitialAdWidget(
      child: Scaffold(
        appBar: UiUtils.getSimpleAppBar(
            context: context,
            title: "chat".translate(context: context),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 15),
                child: CustomToolTip(
                  toolTipMessage: "customerSupport".translate(context: context),
                  child: CustomInkWellContainer(
                    onTap: () {
                      Navigator.pushNamed(context, chatMessages, arguments: {
                        "chatUser": ChatUser(
                          id: "-",
                          name: "customerSupport".translate(context: context),
                          receiverType: "0",
                          unReadChats: 0,
                          bookingId: "-1",
                          senderId: context.read<UserDetailsCubit>().getUserDetails().id ?? "0",
                        ),
                      });
                    },
                    child: Icon(
                      Icons.support_agent,
                      color: context.colorScheme.blackColor,
                    ),
                  ),
                ),
              )
            ]),
        bottomNavigationBar: const BannerAdWidget(),
        body: BlocBuilder<ChatUsersCubit, ChatUsersState>(
          builder: (context, state) {
            if (state is ChatUsersFetchSuccess) {
              return state.chatUsers.isEmpty
                  ? Center(
                      child: NoDataFoundWidget(
                        titleKey: "noChatsFound".translate(context: context),
                      ),
                    )
                  : CustomRefreshIndicator(
                      displacment: 12,
                      onRefreshCallback: () {
                        fetchChatUsers();
                      },
                      child: SizedBox(
                        height: double.maxFinite,
                        width: double.maxFinite,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              ...List.generate(
                                state.chatUsers.length,
                                (index) {
                                  final currentChatUser = state.chatUsers[index];

                                  return ChatUserItemWidget(
                                    chatUser: currentChatUser.copyWith(
                                      receiverType: "1",
                                      unReadChats: 0,
                                      id: state.chatUsers[index].providerId,
                                      bookingId: state.chatUsers[index].bookingId.toString(),
                                      bookingStatus: state.chatUsers[index].bookingStatus
                                          .toString()
                                          .translate(context: context),
                                      name: state.chatUsers[index].name.toString(),
                                      profile: state.chatUsers[index].profile,
                                      senderId:
                                          context.read<UserDetailsCubit>().getUserDetails().id ??
                                              "0",
                                    ),
                                  );
                                },
                              ),
                              if (state.moreChatUserFetchProgress) _buildOneChatUserShimmerLoader(),
                              if (state.moreChatUserFetchError && !state.moreChatUserFetchProgress)
                                CustomLoadingMoreContainer(
                                  isError: true,
                                  onErrorButtonPressed: () {
                                    context.read<ChatUsersCubit>().fetchMoreChatUsers();
                                  },
                                ),
                              const SizedBox(
                                height: 80,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
            }
            if (state is ChatUsersFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    fetchChatUsers();
                  },
                ),
              );
            }
            return _buildShimmerLoader();
          },
        ),
      ),
    );
  }
}
