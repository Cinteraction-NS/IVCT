// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../../core/ui/images/image.dart';
import 'stub.dart';

/// Renders a SIGN IN button that calls `handleSignIn` onclick.
Widget buildSignInButton({HandleSignInFn? onPressed}) {
  return         SizedBox(
    width: 70,
    height: 60,
    child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
              width: 1,
              color: Color(0xFFBDBDBD)),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
                width: 1,
                color: Color(0xFFBDBDBD)),
            borderRadius:
            BorderRadius.circular(18),
          ),
        ),
        child:
        imageSVGAsset('google_logo')),
  );
}