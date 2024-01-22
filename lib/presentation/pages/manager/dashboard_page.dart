import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:select_form_field/select_form_field.dart';

import '../../providers/addon_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/coupon_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/setting_provider.dart';
import '../../widgets/dashboard/dashboard_card.dart';
import '../../widgets/dashboard/dashboard_section_header.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String salesReportRate = 'today';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          scrolledUnderElevation: 5,
          title: const Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DashboardSectionHeader(
                title: "Sales Report",
                icon: Icons.pie_chart_outline,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SelectFormField(
                        type: SelectFormFieldType.dropdown,
                        items: const [
                          {
                            'value': 'today',
                            'label': 'Today',
                          },
                          {
                            'value': 'week',
                            'label': 'This Week',
                          },
                          {
                            'value': 'month',
                            'label': 'This Month',
                          },
                          {
                            'value': 'year',
                            'label': 'This Year',
                          },
                        ],
                        initialValue: 'today',
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          icon: const Icon(MdiIcons.calendar),
                          prefixIconColor: SettingProvider().primaryColor,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 5),
                          isCollapsed: true,
                        ),
                        onChanged: (val) {
                          setState(() {
                            salesReportRate = val;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              FutureBuilder(
                  future: OrderProvider().getSalesReport(salesReportRate),
                  builder: (context, snapshot) {
                    final sale = snapshot.data;
                    final loading =
                        snapshot.connectionState == ConnectionState.waiting;
                    return Wrap(
                      alignment: WrapAlignment.start,
                      children: [
                        DashboardCard(
                          color: Colors.green,
                          content: sale?.orderCount.toString() ?? "0",
                          title: "Total Orders",
                          icon: const Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                          ),
                          loading: loading,
                        ),
                        DashboardCard(
                          color: Colors.deepOrange,
                          content: sale?.itemCount.toString() ?? "0",
                          title: "Total Items",
                          icon: const Icon(
                            Icons.category,
                            color: Colors.white,
                          ),
                          loading: loading,
                        ),
                        DashboardCard(
                          color: Colors.blueAccent,
                          content: "₱ ${sale?.grandTotal.toString() ?? "0"}",
                          title: "Sales",
                          icon: const Icon(
                            Icons.bar_chart,
                            color: Colors.white,
                          ),
                          loading: loading,
                        ),
                      ],
                    );
                  }),
              const Divider(),
              const DashboardSectionHeader(
                title: "System",
                icon: MdiIcons.formatListChecks,
              ),
              Wrap(
                alignment: WrapAlignment.start,
                children: [
                  Consumer<ProductProvider>(
                    builder: (context, productProvider, child) {
                      return DashboardCard(
                        color: Colors.brown.shade400,
                        content: productProvider.products.length.toString(),
                        title: "Products",
                        icon: const Icon(
                          Icons.fastfood,
                          color: Colors.white,
                        ),
                        loading: productProvider.isLoading,
                        action: () {
                          Navigator.pushNamed(context, '/manager',
                              arguments: 'products');
                        },
                      );
                    },
                  ),
                  Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, child) {
                      return DashboardCard(
                        color: Colors.pinkAccent,
                        content: categoryProvider.categories.length.toString(),
                        title: "Categoris",
                        icon: const Icon(
                          Icons.category,
                          color: Colors.white,
                        ),
                        loading: categoryProvider.isLoading,
                        action: () {
                          Navigator.pushNamed(context, '/manager',
                              arguments: 'categories');
                        },
                      );
                    },
                  ),
                  Consumer<AddonProvider>(
                      builder: (context, addonProvider, child) {
                    return DashboardCard(
                      color: Colors.purple,
                      content: addonProvider.addons.length.toString(),
                      title: "Addons",
                      icon: const Icon(
                        MdiIcons.foodVariant,
                        color: Colors.white,
                      ),
                      loading: addonProvider.isLoading,
                      action: () {
                        Navigator.pushNamed(context, '/manager',
                            arguments: 'addons');
                      },
                    );
                  }),
                  Consumer<CouponProvider>(
                      builder: (context, couponProvider, child) {
                    return DashboardCard(
                      color: Colors.teal,
                      content: couponProvider.coupons.length.toString(),
                      title: "Coupons",
                      icon: const Icon(
                        Icons.local_offer,
                        color: Colors.white,
                      ),
                      loading: couponProvider.isLoading,
                      action: () {
                        Navigator.pushNamed(context, '/manager',
                            arguments: "coupons");
                      },
                    );
                  })
                ],
              )
            ],
          ),
        ));
  }
}
