import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../constants/colors.dart';

class QuiSomScreen extends StatelessWidget {
  const QuiSomScreen({super.key});

  final String textQuiSom = """
**Sobre l’autor**

Sóc Àlex Fernández Rascón, estudiant del Grau en Enginyeria Informàtica a la Universitat Autònoma de Barcelona (UAB). Aquest projecte, anomenat *TerritoCAT*, constitueix el meu Treball de Fi de Grau (TFG) i s’ha desenvolupat en col·laboració amb el Centre de Visió per Computador (CVC), sota la tutoria de Josep Jadós i Adrià Molina.

**Origen i motivació del projecte**

La idea neix de la necessitat de preservar, actualitzar i redescobrir el patrimoni fotogràfic i històric de Catalunya. Vivim en una època de transformacions urbanes ràpides, on la memòria col·lectiva pot perdre’s fàcilment. Aquest TFG busca donar resposta a aquesta problemàtica aprofitant la tecnologia mòbil i la participació ciutadana.

**Què és TerritoCAT?**

TerritoCAT és una aplicació mòbil gamificada que convida els usuaris a explorar el territori català, redescobrint llocs històrics a través de fotografies antigues. Els participants poden localitzar aquests punts, fer una nova fotografia des del mateix lloc, i així “conquerir” punts i comarques. Aquestes aportacions s’integren en una xarxa col·laborativa que contribueix a renovar el fons visual de la Xarxa d’Arxius Comarcals de Catalunya.

**Finalitat educativa i social**

Més enllà del desenvolupament tècnic, TerritoCAT és una eina per enfortir la identitat cultural i fomentar l’interès per la història local, especialment entre els joves. A través d’una experiència lúdica, el projecte pretén apropar el patrimoni històric a la ciutadania i implicar-la activament en la seva conservació.

**Agraïments**

Vull expressar el meu agraïment al Centre de Visió per Computador, als meus tutors Josep Jadós i Adrià Molina, i a totes les persones que han donat suport durant el desenvolupament d’aquest TFG.
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.groc,
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: const Text('Qui som', style: TextStyle(color: AppColors.groc)),
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
              data: textQuiSom,
              styleSheet: MarkdownStyleSheet(
                h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                p: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
