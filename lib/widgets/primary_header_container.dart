import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/widgets/circular_container.dart';
import 'package:ecommerce_computer_client/widgets/curved_edges_widget.dart';
import 'package:flutter/material.dart';

class TPrimaryHeaderContainer extends StatelessWidget {
  const TPrimaryHeaderContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TCurvedEdgesWidget(
      child: Container(
        color: TColors.primary,
        child: Stack(
          children: [
            // Background Custom Shapes
            Positioned(
              top: -150,
              right: -250,
              child: CircularContainer(
                backgroundColor: TColors.textWhite.withOpacity(0.1),
              ),
            ),
            Positioned(
              top: 100,
              right: -300,
              child: CircularContainer(
                backgroundColor: TColors.textWhite.withOpacity(0.1),
              ),
            ),
            // Child content
            child,
          ],
        ),
      ),
    );
  }
}
