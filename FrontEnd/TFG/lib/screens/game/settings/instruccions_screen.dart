import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../constants/colors.dart';

class InstruccionsScreen extends StatelessWidget {
  const InstruccionsScreen({super.key});

  final String textInstruccions = """
**Benvingut a TerritoCAT!**

Aquesta aplicació et permet descobrir, explorar i preservar el patrimoni històric de Catalunya d’una manera divertida i participativa.

---

**1. Com funciona?**

- Al mapa podràs veure els punts històrics disponibles a prop teu.
- Quan t’apropis a un punt (dins d’una distància permesa), podràs accedir a la fotografia històrica del lloc.
- Se’t convida a fer una fotografia actual del mateix lloc. Aquesta acció et permetrà **conquerir el punt**.

---

**2. Conquesta de punts i comarques**

- Cada fotografia que facis d’un punt històric et suma **1 punt conquerit**.
- Quan aconsegueixes **5 punts** dins d’una mateixa comarca, **conquereixes la comarca sencera**.
- Pots consultar el teu progrés i la teva col·lecció de comarques a l’apartat de **Col·lecció**.

---

**3. Classificació**

- A la pestanya de **Classificació** podràs veure el rànquing de jugadors.
- L’ordre es determina pel nombre de comarques conquerides i, en cas d’empat, pel nombre de punts.

---

**4. Gestió de l’usuari**

- Un cop iniciada la sessió, no caldrà identificar-te cada vegada que obris l’app.
- Pots consultar o copiar el teu identificador des de l’apartat **El meu identificador** a Configuració.
- Si tanques sessió, hauràs d’introduir aquest codi per recuperar el teu progrés.

---

**5. Contribució**

- Totes les fotografies actuals que facis poden ser visibles per altres usuaris.
- Aquestes contribucions serveixen per enriquir el fons d’imatges de la **Xarxa d’Arxius Comarcals de Catalunya**.

---

**6. Consells**

- Intenta col·locar-te en el mateix angle que la foto original per aconseguir una bona comparació.
- Respecta l’entorn i les persones mentre fas les fotografies.
- Revisa la teva col·lecció sovint per veure com evoluciona el teu mapa de conquesta!

---

**Gràcies per formar part de la comunitat TerritoCAT.**
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.groc,
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: const Text('Instruccions', style: TextStyle(color: AppColors.groc)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: MarkdownBody(
              data: textInstruccions,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 14, height: 1.5),
                h2: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
