import 'package:flutter/material.dart';
import 'package:tractian_mobile_engineer_test/controllers/home_controller.dart';
import 'package:tractian_mobile_engineer_test/pages/assets_page.dart';
import 'package:tractian_mobile_engineer_test/theme/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeController controller;
  @override
  void initState() {
    controller = HomeController();
    controller.addListener(() {
      setState(() {});
    });
    controller.getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/images/logo.png'),
      ),
      body: ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (controller.haveError) {
              return Center(
                child: Text(controller.errorMsg),
              );
            } else if (controller.isEmpty) {
              return const Center(
                child: Text('No data found'),
              );
            } else {
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: controller.value.length,
                itemBuilder: (context, index) {
                  final unit = controller.value[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                        color: unityColor,
                        borderRadius: BorderRadius.circular(5)),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AssetsPage(unitId: unit.id)));
                      },
                      contentPadding: EdgeInsets.all(15),
                      title: Row(
                        children: [
                          Image.asset(
                            'assets/images/unit.png',
                            color: Colors.white,
                            width: 30,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            "${unit.name} Unit",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }),
    );
  }
}
