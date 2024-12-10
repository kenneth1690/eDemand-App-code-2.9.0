import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadInvoiceButton extends StatelessWidget {
  final String bookingId;
  final String buttonScreenName;

  const DownloadInvoiceButton({super.key, required this.bookingId, required this.buttonScreenName});

  Future<bool> checkStoragePermission() async {
    final status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      if (statuses[Permission.storage] == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DownloadInvoiceCubit, DownloadInvoiceState>(
      listener: (final BuildContext context, DownloadInvoiceState state) async {
        if (state is DownloadInvoiceSuccess) {
          if (state.bookingId == bookingId && buttonScreenName == state.buttonScreenName) {
            try {
              final bool checkPermission = await checkStoragePermission();

              final appDocDirPath = Platform.isAndroid && checkPermission
                  ? (await ExternalPath.getExternalStoragePublicDirectory(
                      ExternalPath.DIRECTORY_DOWNLOADS,
                    ))
                  : (await getApplicationDocumentsDirectory()).path;

              final targetFileName =
                  "$appName-${"invoice".translate(context: context)}-$bookingId.pdf";

              final File file = File("$appDocDirPath/$targetFileName");

              // Write down the file as bytes from the bytes got from the HTTP request.
              await file.writeAsBytes(state.invoiceData).then((final value) {
                UiUtils.showMessage(
                  context,
                  "invoiceDownloadedSuccessfully".translate(context: context),
                  MessageType.success,
                );

                OpenFilex.open(file.path);
              });
            } catch (e) {
              UiUtils.showMessage(
                context,
                "somethingWentWrong".translate(context: context),
                MessageType.error,
              );
            }
          }
        } else if (state is DownloadInvoiceFailure) {
          if (state.bookingId == bookingId)
            UiUtils.showMessage(
                context, state.errorMessage.translate(context: context), MessageType.error);
        }
      },
      builder: (final BuildContext context, final DownloadInvoiceState state) {
        Widget? child;
        if (state is DownloadInvoiceInProgress) {
          if (state.bookingId == bookingId && buttonScreenName == state.buttonScreenName)
            child = const CustomCircularProgressIndicator(color: AppColors.whiteColors);
        }
        return Align(
          alignment: Alignment.bottomCenter,
          child: CustomRoundedButton(
            onTap: () {
              context
                  .read<DownloadInvoiceCubit>()
                  .downloadInvoice(bookingId: bookingId, buttonScreenName: buttonScreenName);
            },
            backgroundColor: context.colorScheme.accentColor.withAlpha(30),
            radius: UiUtils.borderRadiusOf5,
            buttonTitle: "",
            showBorder: false,
            widthPercentage: 0.9,
            titleColor: context.colorScheme.accentColor,
            shadowColor: context.colorScheme.accentColor.withAlpha(30),
            child: child ??
                CustomText("downloadInvoice".translate(context: context),
                    maxLines: 1,
                    color: context.colorScheme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
          ),
        );
      },
    );
  }
}
