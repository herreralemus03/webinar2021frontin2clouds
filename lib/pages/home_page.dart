import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outbound/models/status.dart';
import 'package:outbound/providers/dashboard_provider.dart';
import 'package:outbound/widgets/card_counter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DashboardProvider dashboardProvider = DashboardProvider();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response>(
        future: dashboardProvider.getData(),
        builder: (context, snapshot) => buildBody(snapshot));
  }

  Widget buildBody(AsyncSnapshot<Response> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return buildLoading();
    } else if (snapshot.hasError) {
      return buildError(snapshot.error);
    } else if (snapshot.hasData) {
      if (snapshot.data?.values.isNotEmpty ?? true) {
        final stopped = (snapshot.data?.stopped ?? true);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.science),
              tooltip: "Testing",
              onPressed: () {
                final phoneInput = TextEditingController();
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Container(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: "Ej: 50372198058",
                              label: Text("Telefono"),
                            ),
                            controller: phoneInput,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("CANCELAR"),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.call),
                            onPressed: () => Navigator.pop(context, true),
                            label: const Text("LLAMAR"),
                          ),
                        ],
                      );
                    }).then(
                  (value) {
                    if (value ?? false) {
                      dashboardProvider.callSingle(phone: phoneInput.text).then(
                            (value) =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Llamando a +${phoneInput.text}",
                                ),
                              ),
                            ),
                          );
                    }
                  },
                );
              },
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            title: Image.asset(
              "assets/img/In2Cloud-logo.png",
              scale: 12.0,
            ),
            actions: [
              IconButton(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh),
              )
            ],
          ),
          body: Column(
            children: [
              Expanded(flex: 4, child: buildCounters(snapshot.data)),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    "TOTAL\n\n${snapshot.data?.values.map((e) => e.value).reduce((a, b) => a + b)}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Powered by",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Image.asset(
                            "assets/img/aws-logo.png",
                            scale: 25,
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (loading) return;
              loading = true;
              if (stopped) {
                dashboardProvider.updateFlowStatus(status: "PLAYING").then(
                    (value) => dashboardProvider
                        .callGroup()
                        .then((value) => setState(() {
                              loading = false;
                            })));
              } else {
                dashboardProvider
                    .updateFlowStatus(status: "STOPPED")
                    .then((value) => setState(() {
                          loading = false;
                        }));
              }
            },
            child: Icon(stopped ? Icons.stop : Icons.play_arrow),
            backgroundColor: stopped ? Colors.redAccent : Colors.green,
          ),
        );
      } else {
        return buildEmptyContent();
      }
    } else {
      return buildLoading();
    }
  }

  Widget buildCounters(Response? data) {
    final crossAxisCount = data?.values.length ?? 0;

    return GridView(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: (MediaQuery.of(context).size.width / crossAxisCount) /
            (MediaQuery.of(context).size.height / 2),
      ),
      children: (data?.values ?? [])
          .map(
            (element) => buildCard(element.title, element.value),
          )
          .toList(),
    );
  }

  String title = "";

  void buildTitle(index) {
    switch (index) {
      case 0:
        dashboardProvider.callGroup();
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
          builder: (context) => buildModalContent(label),
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
            final people = (snapshot.data?.values ?? []).toList();
            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 35,
              ),
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                final person = people[index];
                return ListTile(
                  leading: const Icon(Icons.call),
                  title: Text("${person['nombre']} ${person['apellido']}"),
                  subtitle: Text("${person['telefono']}"),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title:
                              Text("${person["nombre"]} ${person["apellido"]}"),
                          content: Container(
                            child: Text("¿Llamar a ${person['telefono']}?"),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("CANCELAR")),
                            TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text("LLAMAR")),
                          ],
                        );
                      },
                    ).then((value) {
                      Navigator.of(context).pop();
                      if (value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "LLamando a ${person['nombre']} ${person['apellido']}")));
                        dashboardProvider.callSingle(phone: person['telefono']);
                      }
                    });
                  },
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
