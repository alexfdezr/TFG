import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../constants/colors.dart';

class InformacioLegalScreen extends StatelessWidget {
  const InformacioLegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const textLegal = '''
## Informació legal

Aquest document recull la informació legal relativa a l'ús de l'aplicació **TerritoCAT**, desenvolupada com a part d'un projecte acadèmic del Treball de Fi de Grau en Enginyeria Informàtica de la Universitat Autònoma de Barcelona (UAB). L'aplicació no té ànim de lucre i està dissenyada exclusivament amb finalitats culturals, educatives i de participació ciutadana.

### 1. Propòsit i naturalesa de l’aplicació

TerritoCAT és una aplicació mòbil dissenyada per fomentar la conservació del patrimoni visual de Catalunya. Els usuaris poden contribuir amb fotografies actuals de llocs històrics per complementar el fons fotogràfic de la Xarxa d'Arxius Comarcals de Catalunya. Aquesta aplicació no genera cap tipus d’ingrés i no està vinculada a cap entitat comercial.

### 2. Dades personals i geolocalització

L’aplicació pot utilitzar la ubicació del dispositiu únicament per detectar si l’usuari es troba a prop d’un punt històric i permetre la captura d’imatges. Aquesta informació no s’emmagatzema de forma permanent ni s’utilitza per rastrejar els moviments de l’usuari.

Les dades d'identificació (nom i codi generat automàticament) s'utilitzen exclusivament per a l’ús intern del joc i no són compartides amb tercers en cap cas.

### 3. Fotografies dels usuaris

Les fotografies realitzades pels usuaris tenen com a únic propòsit enriquir la col·lecció d’imatges del patrimoni visual de Catalunya. Aquestes imatges poden ser vistes per altres usuaris dins de l’aplicació, però en cap cas seran comercialitzades ni utilitzades fora d’aquest àmbit.

L’usuari entén i accepta que, en capturar i enviar una fotografia, cedeix el dret d'ús d’aquesta imatge a efectes de difusió cultural dins l’aplicació i per a finalitats relacionades amb la divulgació patrimonial.

### 4. Ús responsable i continguts

L’usuari es compromet a no enviar imatges que continguin contingut ofensiu, il·legal o que vulneri drets d’autoria o privacitat de tercers. En cas de detectar contingut inadequat, l’organització responsable del projecte es reserva el dret d’eliminar-lo.

### 5. Limitació de responsabilitat

L’aplicació s’ofereix “tal com és” i no es garanteix l’absència d’errors o interrupcions. Els desenvolupadors no es fan responsables dels danys que puguin derivar-se de l’ús inadequat o no autoritzat de l’aplicació.

### 6. Propietat intel·lectual

Tots els elements visuals i de programació desenvolupats específicament per a l’aplicació són propietat dels seus autors acadèmics i no poden ser reutilitzats per a usos comercials sense autorització expressa.

### 7. Contacte

Per a qualsevol dubte legal o qüestió relacionada amb el projecte, podeu contactar amb el responsable del projecte a través dels canals habilitats per la Universitat Autònoma de Barcelona.

---

Aquest text pot estar subjecte a actualitzacions en futures versions de l'aplicació.
''';

    return Scaffold(
      backgroundColor: AppColors.groc,
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: const Text('Informació legal', style: TextStyle(color: AppColors.groc)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: MarkdownBody(
              data: textLegal,
              styleSheet: MarkdownStyleSheet(
                h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                h3: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                p: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
