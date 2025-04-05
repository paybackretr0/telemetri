import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showNotification;
  final Function()? onBackPressed;
  final double titleLeftPadding;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.showNotification = true,
    this.onBackPressed,
    this.titleLeftPadding = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> defaultActions = [];
    if (showNotification) {
      defaultActions.add(
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/notification');
          },
        ),
      );
    }

    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
              : null,
      title: Padding(
        padding: EdgeInsets.only(left: titleLeftPadding),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      actions: actions ?? defaultActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
