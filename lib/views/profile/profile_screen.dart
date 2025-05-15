import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/widgets/appbar.dart';
import 'package:ecommerce_computer_client/widgets/circular_image.dart';
import 'package:ecommerce_computer_client/widgets/profile_menu.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Sizes.defaultSpace),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align all children to the left
            children: [
              /// Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    CircularImage(
                      imageUrl: 'assets/images/user.png',
                      width: 100,
                      height: 100,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Change Profile Picture',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Details
              const SizedBox(height: Sizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: Sizes.spaceBtwItems),
              const Text(
                'Profile Information',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwItems),

              ProfileMenu(
                title: 'Name',
                value: 'Coding with Q',
                onPressed: () {},
              ),
              ProfileMenu(
                title: 'Username',
                value: 'coding_with_q',
                onPressed: () {},
              ),
              const SizedBox(height: Sizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: Sizes.spaceBtwItems),

              /// Heading Personal Info
              const Text(
                'Personal Information',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwItems),

              ProfileMenu(title: 'User ID', value: '456799', onPressed: () {}),
              ProfileMenu(
                title: 'Email',
                value: 'quangiter74@gmail.com',
                onPressed: () {},
              ),
              ProfileMenu(
                title: 'Phone number',
                value: '+ 84-344-470-696',
                onPressed: () {},
              ),
              ProfileMenu(title: 'Gender', value: 'Male', onPressed: () {}),
              ProfileMenu(
                title: 'Date of Birth',
                value: '10 Oct, 2004',
                onPressed: () {},
              ),
              const Divider(),
              const SizedBox(height: Sizes.spaceBtwItems),

              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwItems),
              const Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
