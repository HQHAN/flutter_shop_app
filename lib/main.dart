import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/orders_provider.dart';
import 'package:shop/providers/products_provider.dart';
import 'package:shop/screen/auth_screen.dart';
import 'package:shop/screen/cart_screen.dart';
import 'package:shop/screen/edit_product_screen.dart';
import 'package:shop/screen/order_screen.dart';
import 'package:shop/screen/product_detail_screen.dart';
import 'package:shop/screen/product_overview_screen.dart';
import 'package:shop/screen/splash_screen.dart';
import 'package:shop/screen/user_product_screen.dart';
import 'helper/page_transition_animation.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductProvider>(
          create: (ctx) => ProductProvider(),
          update: (ctx, auth, previousProvider) {
            return (previousProvider..authToken = auth.token)
              ..userId = auth.userId;
          },
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders(),
          update: (ctx, auth, previousProvider) {
            return (previousProvider..authToken = auth.token)
              ..userId = auth.userId;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            fontFamily: 'Lato',
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            })),
        home: Consumer<Auth>(builder: (ctx, auth, _) {
          return auth.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authSnapshot) {
                    if (authSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return SplashScreen();
                    }
                    return AuthScreen();
                  },
                );
        }),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrderScreen.routeName: (ctx) => OrderScreen(),
          UserProductScreen.routeName: (ctx) => UserProductScreen(),
          EditProductScreen.routeName: (ctx) => EditProductScreen(),
        },
      ),
    );
  }
}
