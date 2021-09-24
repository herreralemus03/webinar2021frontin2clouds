import 'package:flutter/material.dart';
import 'package:outbound/providers/dashboard_provider.dart';
import 'package:outbound/widgets/card_counter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DashboardProvider dashboardProvider = DashboardProvider();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Container(
        child: FutureBuilder<Map<String, int>>(
          future: dashboardProvider.getData(),
          builder: (context, snapshot) => buildBody(snapshot),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: buildTitle,
        items: const [
          BottomNavigationBarItem(
            label: "Iniciar",
            icon: Icon(
              Icons.play_arrow,
              color: Colors.green,
            ),
          ),
          BottomNavigationBarItem(
            label: "Parar",
            icon: Icon(
              Icons.stop,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody(AsyncSnapshot<Map<String, int>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return buildLoading();
    } else if (snapshot.hasError) {
      return buildError(snapshot.error);
    } else if (snapshot.hasData) {
      if (snapshot.data?.isNotEmpty ?? true) {
        return Column(
          children: [
            Expanded(flex: 1, child: buildCounters(snapshot.data ?? {})),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  "TOTAL\n\n${snapshot.data?.values.reduce((a, b) => a + b)}",
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        );
      } else {
        return buildEmptyContent();
      }
    } else {
      return buildLoading();
    }
  }

  Widget buildCounters(Map<String, int> data) {
    final crossAxisCount = data.length;

    return GridView(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: (MediaQuery.of(context).size.width / crossAxisCount) /
            (MediaQuery.of(context).size.height / 2),
      ),
      children: data
          .map(
            (key, value) => MapEntry(
              key,
              buildCard(key, value),
            ),
          )
          .values
          .toList(),
    );
  }

  String title = "";

  void buildTitle(index) {
    switch (index) {
      case 0:
        dashboardProvider.updateFlowStatus(status: "PLAYING");
        dashboardProvider.doCalls();
        title = "Ejecutandose";
        break;
      case 1:
        dashboardProvider.updateFlowStatus(status: "STOPPED");
        title = "Parado";
        break;
      default:
        break;
    }
    setState(() {});
  }

  Widget buildCard(String label, int amount) {
    return CardCounter(
      aspectRatio: MediaQuery.of(context).size.height / 2,
      amount: amount,
      title: label,
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return FutureBuilder<Map<String, dynamic>>(
              future: dashboardProvider.getList(status: label),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return buildError(snapshot.error);
                } else if (snapshot.hasData) {
                  if (snapshot.data?.isEmpty ?? true) {
                    return buildEmptyContent();
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 35,
                      ),
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.call),
                          title:
                              Text((snapshot.data?.keys ?? []).toList()[index]),
                        );
                      },
                    );
                  }
                }
                if (snapshot.hasData) {}
                return buildLoading();
              },
            );
          },
        );
      },
    );
  }

  Widget buildModalContent(String status) {
    return FutureBuilder<Map<String, dynamic>>(
      future: dashboardProvider.getList(status: status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            constraints: const BoxConstraints(minHeight: 300),
            child: Center(child: Text("Error: ${snapshot.error}")),
          );
        } else if (snapshot.hasData) {
          if (snapshot.data?.isEmpty ?? true) {
            return buildEmptyContent();
          } else {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 35,
              ),
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.call),
                  title: Text((snapshot.data?.keys ?? []).toList()[index]),
                );
              },
            );
          }
        }
        if (snapshot.hasData) {}
        return buildLoading();
      },
    );
  }

  Widget buildError(Object? error) {
    return Center(
      child: Text(
        "Ha ocurrido un error inesperado \n$error",
      ),
    );
  }

  Widget buildEmptyContent() {
    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      child: const Center(child: Text("No hay datos")),
    );
  }

  Widget buildLoading() {
    return Container(
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
