import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    final Key? key,
    // this.phoneNumberWithCountryCode,
    this.phoneNumberWithOutCountryCode,
    this.countryCode,
    this.countryCodeName,
    required this.uid,
    this.source,
    required this.loginType,
    this.userEmail,
    this.userName,
    required this.isNewUser,
  }) : super(key: key);

  //
  final String? phoneNumberWithOutCountryCode;
  final String? countryCode;
  final String? countryCodeName;
  final String uid;
  final String? userEmail;
  final String? userName;
  final LogInType? loginType;
  final String? source;
  final bool isNewUser;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
        builder: (final BuildContext context) {
          Map arguments = {};
          if (routeSettings.arguments != null) {
            arguments = routeSettings.arguments as Map;
          }

          return EditProfileScreen(
            phoneNumberWithOutCountryCode: arguments['phoneNumberWithOutCountryCode'] ?? '',
            countryCode: arguments['countryCode'] ?? '',
            countryCodeName: arguments['countryCodeName'] ?? '',
            source: arguments['source'] ?? '',
            uid: arguments['uid'] ?? '',
            loginType: arguments["loginType"],
            userEmail: arguments["userEmail"] ?? "",
            userName: arguments["userName"] ?? "",
            isNewUser: arguments["isNewUser"],
          );
        },
      );
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  //
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  FocusNode nameFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();

  ValueNotifier<bool> isNameFocused = ValueNotifier<bool>(false);
  ValueNotifier<bool> isPhoneFocused = ValueNotifier<bool>(false);
  ValueNotifier<bool> isEmailFocused = ValueNotifier<bool>(false);

  UserDetailsModel? userDetails;
  File? selectedImage;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameFocusNode.removeListener(_nameFocusNodeListener);
    phoneFocusNode.removeListener(_phoneFocusNodeListener);
    emailFocusNode.removeListener(_emailFocusNodeListener);
    nameFocusNode.dispose();
    phoneFocusNode.dispose();
    emailFocusNode.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    nameFocusNode.addListener(_nameFocusNodeListener);
    phoneFocusNode.addListener(_phoneFocusNodeListener);
    emailFocusNode.addListener(_emailFocusNodeListener);

    Future.delayed(
      Duration.zero,
      () async {
        if (widget.countryCodeName != "" &&
            widget.countryCodeName != null &&
            widget.countryCodeName != 'null') {
          context.read<CountryCodeCubit>().selectCountryCode(
                (await context.read<CountryCodeCubit>().getCountryDetailsFromCountryLocale(
                      context,
                      countryLocale: widget.countryCodeName!,
                    ))!,
              );
        }
      },
    );

    if (widget.phoneNumberWithOutCountryCode != '' &&
        widget.phoneNumberWithOutCountryCode != null &&
        widget.phoneNumberWithOutCountryCode != 'null') {
      phoneNumberController.text = "${widget.countryCode} ${widget.phoneNumberWithOutCountryCode!}";

      Future.delayed(
        Duration.zero,
        () {
          userDetails = context.read<UserDetailsCubit>().getUserDetails();
        },
      );
    } else if (HiveRepository.getUserMobileNumber != null) {
      phoneNumberController.text =
          "${HiveRepository.getUserMobileCountryCode} ${HiveRepository.getUserMobileNumber}";
    }

    if (widget.userEmail != '' && widget.userEmail != null && widget.userEmail != 'null') {
      emailController.text = widget.userEmail!;

      Future.delayed(
        Duration.zero,
        () {
          userDetails = context.read<UserDetailsCubit>().getUserDetails();
        },
      );
    } else if (HiveRepository.getUserEmailId != null) {
      emailController.text = HiveRepository.getUserEmailId ?? "";
    }
    if (widget.userName != '' && widget.userName != null && widget.userName != 'null') {
      usernameController.text = widget.userName!;

      Future.delayed(
        Duration.zero,
        () {
          userDetails = context.read<UserDetailsCubit>().getUserDetails();
        },
      );
    } else if (HiveRepository.getUsername != null) {
      usernameController.text = HiveRepository.getUsername ?? "";
    }
  }

  Future<void> _getFromGallery() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    final croppedFile = await _croppedImage(pickedFile!.path);

    setState(() {
      selectedImage = File(croppedFile!.path);
    });
  }

  Future<CroppedFile?> _croppedImage(String pickedFilePath) async {
    return ImageCropper().cropImage(
      sourcePath: pickedFilePath,
      compressFormat: ImageCompressFormat.png,
      uiSettings: [
        AndroidUiSettings(
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          cropStyle: CropStyle.circle,
          toolbarTitle: "cropImage".translate(context: context),
          toolbarColor: Theme.of(context).colorScheme.accentColor,
          toolbarWidgetColor: AppColors.whiteColors,
          initAspectRatio: CropAspectRatioPreset.square,
          hideBottomControls: true,
          activeControlsWidgetColor: Theme.of(context).colorScheme.primaryColor,
        ),
        IOSUiSettings(
          title: "cropImage".translate(context: context),
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          cropStyle: CropStyle.circle,
        ),
      ],
    );
  }

  @override
  Widget build(final BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primaryColor,
          appBar: UiUtils.getSimpleAppBar(
            context: context,
            title: ''.translate(context: context),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: BlocConsumer<UpdateUserCubit, UpdateUserState>(
                listener: (context, UpdateUserState updateUserState) {
                  if (updateUserState is UpdateUserSuccess) {
                    final existingUserDetails =
                        (context.read<UserDetailsCubit>().state as UserDetails).userDetailsModel;

                    final newUserDetails =
                        existingUserDetails.fromMapCopyWith(updateUserState.updatedDetails.toMap());
                    context.read<UserDetailsCubit>().changeUserDetails(newUserDetails);
                  }
                },
                builder: (final context, UpdateUserState updateUserState) => Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        (widget.isNewUser ? "createProfile" : "editProfile")
                            .translate(context: context),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      CustomInkWellContainer(
                        onTap: () {
                          _getFromGallery();
                        },
                        showRippleEffect: false,
                        child: CustomContainer(
                          width: 100,
                          height: 100,
                          borderRadius: UiUtils.borderRadiusOf50,
                          border: Border.all(
                              color: Theme.of(context).colorScheme.lightGreyColor, width: 0.5),
                          padding: const EdgeInsets.all(12),
                          child: Stack(
                            children: [
                              ClipRRect(
                                //
                                borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
                                //
                                child: selectedImage != null
                                    ? Image.file(
                                        File(
                                          selectedImage?.path ?? "",
                                        ),
                                        width: 100,
                                        height: 100,
                                      )
                                    : (HiveRepository.getUserProfilePictureURL == null ||
                                            HiveRepository.getUserProfilePictureURL == '')
                                        ? const CustomSvgPicture(
                                            svgImage: AppAssets.drProfile,
                                            width: 100,
                                            height: 100,
                                          )
                                        : CustomCachedNetworkImage(
                                            networkImageUrl:
                                                HiveRepository.getUserProfilePictureURL ?? '',
                                            width: 100,
                                            height: 100,
                                          ),
                              ),
                              Align(
                                alignment: AlignmentDirectional.center,
                                child: CustomContainer(
                                  height: 100,
                                  width: 100,
                                  color: Colors.black.withAlpha(10),
                                  borderRadius: UiUtils.borderRadiusOf50,
                                  child: Center(
                                    child: CustomSvgPicture(
                                      svgImage: AppAssets.attCamera,
                                      color: Theme.of(context).colorScheme.secondaryColor,
                                      height: 25,
                                      width: 25,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const CustomSizedBox(height: 28),
                      ValueListenableBuilder<bool>(
                          valueListenable: isNameFocused,
                          builder: (context, value, _) {
                            return CustomTextFormField(
                              labelText: "username".translate(context: context),
                              hintText: "enterUsername".translate(context: context),
                              controller: usernameController,
                              currNode: nameFocusNode,
                              textInputType: TextInputType.name,
                              prefix: _buildPrefixIcon(
                                  iconName: AppAssets.drProfile, isFocused: value),
                              validator: (username) =>
                                  isTextFieldEmpty(context: context, value: username),
                            );
                          }),
                      const CustomSizedBox(
                        height: 10,
                      ),
                      ValueListenableBuilder<bool>(
                          valueListenable: isPhoneFocused,
                          builder: (context, value, _) {
                            return CustomTextFormField(
                              labelText: "phoneNumber".translate(context: context),
                              hintText: "enterPhoneNumber".translate(context: context),
                              currNode: phoneFocusNode,
                              controller: phoneNumberController,
                              isReadOnly: widget.loginType == LogInType.phone,
                              textInputAction: TextInputAction.done,
                              inputFormatters: UiUtils.allowOnlyDigits(),
                              prefix: _buildPrefixIcon(iconName: AppAssets.phone, isFocused: value),
                              textInputType: TextInputType.number,
                              validator: (mobileNumber) {
                                return isTextFieldEmpty(value: mobileNumber, context: context);
                              },
                            );
                          }),
                      const CustomSizedBox(
                        height: 10,
                      ),
                      ValueListenableBuilder<bool>(
                          valueListenable: isEmailFocused,
                          builder: (context, value, _) {
                            return CustomTextFormField(
                              labelText: "email".translate(context: context),
                              hintText: "enterYourEmailAddress".translate(context: context),
                              controller: emailController,
                              currNode: emailFocusNode,
                              prefix: _buildPrefixIcon(iconName: AppAssets.email, isFocused: value),
                              isReadOnly: widget.loginType == LogInType.apple ||
                                  widget.loginType == LogInType.google,
                              textInputType: TextInputType.emailAddress,
                              validator: (email) =>
                                  isValidEmail(email: email ?? "", context: context),
                            );
                          }),
                      const CustomSizedBox(
                        height: 50,
                      ),
                      BlocConsumer<UpdateUserCubit, UpdateUserState>(
                        listener: (final context, final state) {
                          if (state is UpdateUserSuccess) {
                            UiUtils.showMessage(
                              context,
                              "profileUpdateSuccess".translate(context: context),
                              MessageType.success,
                            );

                            if (!widget.isNewUser) {
                              //user is editing their profile details
                              Navigator.pop(context);
                            }
                          } else if (state is UpdateUserFail) {
                            UiUtils.showMessage(
                              context,
                              state.error.translate(context: context),
                              MessageType.error,
                            );
                          }
                        },
                        builder: (final BuildContext context, UpdateUserState state) {
                          Widget? child;
                          if (state is UpdateUserInProgress) {
                            child =
                                const CustomCircularProgressIndicator(color: AppColors.whiteColors);
                          } else if (state is UpdateUserSuccess || state is UpdateUserFail) {
                            child = null;
                          }
                          return CustomSizedBox(
                            width: MediaQuery.sizeOf(context).width,
                            height: 48,
                            child: CustomRoundedButton(
                              onTap: () => _handleSaveChangesClick(context, state),
                              buttonTitle: (widget.isNewUser ? "continue" : "saveChanges")
                                  .translate(context: context),
                              backgroundColor: Theme.of(context).colorScheme.accentColor,
                              showBorder: false,
                              widthPercentage: 0.9,
                              child: child,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildPrefixIcon({required String iconName, required bool isFocused}) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 12, 0, 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSvgPicture(
            svgImage: iconName,
            color: isFocused ? context.colorScheme.accentColor : context.colorScheme.lightGreyColor,
          ),
          const SizedBox(
            width: 10,
          ),
          SizedBox(
            height: 15,
            child: VerticalDivider(
              width: 0.5,
              color:
                  isFocused ? context.colorScheme.accentColor : context.colorScheme.lightGreyColor,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveChangesClick(BuildContext context, UpdateUserState state) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    UiUtils.removeFocus();
    if (state is UpdateUserInProgress) {
      return;
    }
    //if user is registering their profile first time
    if (widget.isNewUser) {
      final latitude = HiveRepository.getLatitude ?? "0.0";
      final longitude = HiveRepository.getLongitude ?? "0.0";

      String? fcmId;
      try {
        await FirebaseMessaging.instance.getToken().then((value) async {
          fcmId = value;
        });
      } catch (_) {}

      await AuthenticationRepository.loginUser(
              uid: widget.uid,
              fcmId: fcmId,
              latitude: latitude.toString(),
              longitude: longitude.toString(),
              loginType: widget.loginType!,
              mobileNumber: widget.phoneNumberWithOutCountryCode,
              countryCode: widget.countryCode)
          .then(
        (final UserDetailsModel value) async {
          //
          context.read<UserDetailsCubit>().setUserDetails(value);
          //
          final UpdateUserDetails updateUserDetails = UpdateUserDetails(
            email: emailController.value.text.trim().toString(),
            phone: widget.loginType == LogInType.phone
                ? widget.phoneNumberWithOutCountryCode
                    .toString()
                    .replaceAll(widget.countryCode.toString(), "")
                : phoneNumberController.text.trim().toString(),
            countryCode: widget.loginType == LogInType.phone ? widget.countryCode : "",
            countryCodeName: "",
            username: usernameController.value.text.trim().toString(),
            image: selectedImage ?? "",
            loginType: widget.loginType?.name.toString(),
            uid: widget.uid,
          );
          //
          await context.read<UpdateUserCubit>().updateUserDetails(updateUserDetails);

          //update user authenticated status
          HiveRepository.setUserFirstTimeInApp = false;
          HiveRepository.setUserLoggedIn = true;

          if (mounted) {
            context.read<AuthenticationCubit>().checkStatus();
          }
          //
          Future.delayed(
            Duration.zero,
            () {
              if (widget.source == "dialog") {
                try {
                  context.read<BookingCubit>().fetchBookingDetails(status: '');
                  context.read<CartCubit>().getCartDetails(isReorderCart: false);
                  context.read<BookmarkCubit>().fetchBookmark(type: 'list');
                  context.read<UserDetailsCubit>().loadUserDetails();
                } catch (_) {}
                //
                Navigator.pop(context);
                Navigator.pop(context);
              } else {
                UiUtils.bottomNavigationBarGlobalKey.currentState
                    ?.selectedIndexOfBottomNavigationBar.value = 0;

                Navigator.pop(context);

                Navigator.pushReplacementNamed(context, navigationRoute);
              }
            },
          );
        },
      );
    } else {
      //if user is editing their profile then directly update their data

      final UpdateUserDetails updateUserDetails = UpdateUserDetails(
        email: emailController.value.text,
        phone: widget.loginType == LogInType.phone
            ? widget.phoneNumberWithOutCountryCode
                .toString()
                .replaceAll(widget.countryCode.toString(), "")
            : phoneNumberController.text.trim().toString(),
        countryCode: widget.loginType == LogInType.phone ? widget.countryCode : "",
        countryCodeName: "",
        username: usernameController.value.text,
        image: selectedImage ?? "",
        loginType: widget.loginType?.name.toString(),
        uid: widget.uid,
      );

      context.read<UpdateUserCubit>().updateUserDetails(updateUserDetails);
    }
  }

  void _nameFocusNodeListener() {
    isNameFocused.value = nameFocusNode.hasFocus;
  }

  void _phoneFocusNodeListener() {
    isPhoneFocused.value = phoneFocusNode.hasFocus;
  }

  void _emailFocusNodeListener() {
    isEmailFocused.value = emailFocusNode.hasFocus;
  }
}
