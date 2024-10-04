import 'package:flutter/material.dart';

class PurchaseView extends StatefulWidget {
  @override
  _PurchaseViewState createState() => _PurchaseViewState();
}

class _PurchaseViewState extends State<PurchaseView> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro
      body: SafeArea(
        child: Column(
          children: [
            Text(
              "Amplia tu plan Rumbero",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  PlanView(plan: Plan.standard),
                  PlanView(plan: Plan.pro),
                  PlanView(plan: Plan.djPro),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlanView extends StatefulWidget {
  final Plan plan;

  const PlanView({Key? key, required this.plan}) : super(key: key);

  @override
  _PlanViewState createState() => _PlanViewState();
}

class _PlanViewState extends State<PlanView> {
  bool showCompletePlan = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.only(bottom: 15.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del plan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Plan ${widget.plan.title}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.plan == Plan.djPro)
                  Text(
                    "Próximamente",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                if (widget.plan == Plan.pro)
                  Text(
                    "Próximamente",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                if (widget.plan == Plan.standard)
                  ElevatedButton(
                    onPressed: () {
                      // Acción de compra
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Plan.standard.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text("Tu plan"),
                  ),
              ],
            ),
            SizedBox(height: 10),
            // Detalles del plan
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0;
                    i < (showCompletePlan ? widget.plan.details.length : 3);
                    i++)
                  Row(
                    children: [
                      Icon(Icons.circle, size: 10, color: widget.plan.color),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.plan.details[i],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 10),
                // Botón Ver más / Ver menos
                TextButton(
                  onPressed: () {
                    setState(() {
                      showCompletePlan = !showCompletePlan;
                    });
                  },
                  child: Text(
                    showCompletePlan ? "Ver menos" : "Ver más",
                    style: TextStyle(
                      color: widget.plan.color,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Precios
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var price in widget.plan.cost)
                      Chip(
                        label: Text(
                          price,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: widget.plan.color,
                      ),
                  ],
                ),
                SizedBox(height: 5),
                // Duración
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var month in widget.plan.month)
                      Text(
                        month,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum Plan {
  standard,
  pro,
  djPro;

  String get title {
    switch (this) {
      case Plan.standard:
        return "STANDARD";
      case Plan.pro:
        return "PRO";
      case Plan.djPro:
        return "DJ PRO";
    }
  }

  Color get color {
    switch (this) {
      case Plan.standard:
        return Colors.orange;
      case Plan.pro:
        return Colors.blue;
      case Plan.djPro:
        return Colors.green;
    }
  }

  List<String> get details {
    switch (this) {
      case Plan.standard:
        return [
          "Sincronización 10 usuarios",
          "Modo On-line 100%",
          "Entérate de ofertas",
          "Acceso total a la aplicación",
          "Interfaz intuitiva",
          "Perfil activo",
          "Comparte en tus redes sociales que estas rumbeando",
        ];
      case Plan.pro:
        return [
          "Sincronización 10 - 50 usuarios",
          "Chat grupal",
          "Compatibilidad Streaming",
          "Ecualizador integrado",
          "Adios publicidad",
          "Modo offline",
          "Forma parte de RumbaWorld!",
          "App personalizada: Escoge los colores y diseña tu app",
          "Comparte con tus amigos que estas rumbeando",
        ];
      case Plan.djPro:
        return [
          "Sincronización de +100 usuarios",
          "Compatibilidad Streaming",
          "Ecualizador avanzado",
          "Modo Karaoke!",
        ];
    }
  }

  List<String> get cost {
    switch (this) {
      case Plan.standard:
        return ["free"];
      case Plan.pro:
        return ["\$3.00", "\$6.99", "\$19.99"];
      case Plan.djPro:
        return ["\$4.00", "\$9.99", "\$29.99"];
    }
  }

  List<String> get month {
    switch (this) {
      case Plan.standard:
        return ["Por lanzamiento"];
      case Plan.pro:
        return ["mes", "3 meses", "1 año"];
      case Plan.djPro:
        return ["mes", "3 meses", "1 año"];
    }
  }
}
