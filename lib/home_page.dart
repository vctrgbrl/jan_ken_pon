import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

enum Selection {
  pedra, papel, tesoura
}

enum Result {
  won, lose, tie, play
}

enum GameState {
  play, waiting, finish
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Selection? computerChoice;
  bool isShrinking = false;
  Result? result;
  GameState gameState = GameState.play;
  String jokenpoText = "じゃん...";
  int count = 3;
  Selection? playerSelection;
  bool playButtonHover = false;

  startGame() {
    setState(() {
      jokenpoText = "じゃん...";
      result = null;
      playerSelection = null;
      computerChoice = null;
      count = 3;
      gameState = GameState.waiting;
    });

    Future.delayed(const Duration(seconds: 1),() => setState(() {
      jokenpoText = "けん...";
      count--;
    }));

    Future.delayed(const Duration(seconds: 2),() => setState(() {
      jokenpoText = "ぽん...";
      count--;
    }));

    Future.delayed(const Duration(seconds: 3), onTimeOver);
  }

  onTimeOver() {
    setState(() {
      isShrinking = true;
      gameState = GameState.finish;
      computerChoice = Selection.values[Random().nextInt(3)];
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      Result newResult = Result.lose;
      if (playerSelection == null || computerChoice == playerSelection) {
        newResult = Result.tie;
        if (playerSelection == null) {
          newResult = Result.lose;
        }
        setState(() {
          result = newResult;
          isShrinking = false;
        });
        return;
      }
      switch (playerSelection) {
        case Selection.pedra:
          if (computerChoice == Selection.papel) {
            newResult = Result.lose;
          } else {
            newResult = Result.won;
          }
          break;
        case Selection.papel:
          if (computerChoice == Selection.tesoura) {
            newResult = Result.lose;
          } else {
            newResult = Result.won;
          }
          break;
        case Selection.tesoura:
          if (computerChoice == Selection.pedra) {
            newResult = Result.lose;
          } else {
            newResult = Result.won;
          }
          break;
        default:
      }
      setState(() {
        isShrinking = false;
        result = newResult;
      });
    });
  }

  playerSelect(Selection selection) {
    setState(() {
      playerSelection = selection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const FractionallySizedBox(
          widthFactor: 1/2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("じ", style: TextStyle( fontWeight: FontWeight.bold,color: Colors.redAccent),),
              Text("ゃ", style: TextStyle( fontWeight: FontWeight.bold,color: Colors.orangeAccent),),
              Text("ん", style: TextStyle( fontWeight: FontWeight.bold,color: Colors.yellowAccent),),
              Text("け", style: TextStyle( fontWeight: FontWeight.bold,color: Colors.greenAccent),),
              Text("ん", style: TextStyle( fontWeight: FontWeight.bold,color: Colors.cyanAccent),),
              Text("ぽ", style: TextStyle( fontWeight: FontWeight.bold,color: Colors.lightBlueAccent),),
              Text("ん", style: TextStyle( fontWeight: FontWeight.bold,color: Colors.blueAccent),),
              Text("!" , style: TextStyle( fontWeight: FontWeight.bold,color: Colors.purpleAccent)),
            ]
          ),
        ),
        actions: []
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(100),
          image: const DecorationImage(
            opacity: 0.2,
            fit: BoxFit.cover,
            image: AssetImage("assets/jankenpon.png")
          )
        ),
        padding: const EdgeInsets.all(8.0),
        child: gameStateManagerWidget(),
      ),
    );
  }

  Widget gameStateManagerWidget() {
    switch (gameState) {
      case GameState.play:
        return playWidget();
      case GameState.waiting:
        return selectWidget();
      case GameState.finish:
        return finishWidget();
      default:
    }
    return const Text("Algo de errado");
  }

  Widget playAgainButton() {
    return InkWell(
      onTap: () {
        setState(() {
          gameState = GameState.play;
        });
      },
      radius: 20,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(strokeAlign: 4, color: Colors.black54),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          "Jogar Novamente",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, 
          color: Colors.black54),
        ),
      ),
    );
  }

  Widget finishWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          computerButton(computerChoice),
          resultWidget(),
          computerButton(playerSelection),
          playAgainButton()
        ],
      ),
    );
  }

  Widget playWidget() {
    return Center(
      child: InkWell(
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onHover: (value) => setState(() => playButtonHover = value),
        onTap: startGame,
        child: AnimatedContainer(
          padding: EdgeInsets.all(playButtonHover ? 8 : 4),
          height: playButtonHover ? 220 : 200,
          width: playButtonHover ? 220:200,
          duration: const Duration(milliseconds: 200),
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.purple, 
              Colors.deepPurpleAccent],
              ),
            color: Colors.pinkAccent,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text("Vamos Jogar!",
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                fontSize: 30,
              )
            )
          ),
        ),
      ),
    );
  }

  Widget jokenpoWidget() {
    return Column(
      children: [
        Text(jokenpoText, 
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text("$count", style: const TextStyle(color: Colors.black54, fontSize: 30),)
      ],
    );
  }

  Widget selectWidget() {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        jokenpoWidget(),
        const Text("Faça sua escolha!!", 
          style: TextStyle(color: Colors.black87, fontSize: 24),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SelectionWidget(asset: "assets/pedra.png"  ,selection: Selection.pedra  , playerSelection: playerSelection,playGame: playerSelect),
            SelectionWidget(asset: "assets/papel.png"  ,selection: Selection.papel  , playerSelection: playerSelection,playGame: playerSelect),
            SelectionWidget(asset: "assets/tesoura.png",selection: Selection.tesoura, playerSelection: playerSelection,playGame: playerSelect),
          ],
        )
      ]
    );
  }

  Widget resultWidget() {
    String message = "";
    Color color = Color.fromARGB(255, 231, 141, 171);
    switch (result) {
      case Result.lose:
        message = "Você perdeu!";
        color = Colors.redAccent;
        break;
      case Result.won:
        message = "Você venceu...";
        color = Colors.greenAccent;
        break;
      case Result.tie:
        message = "Empatamos, vamos jogar de novo";
        break;
      default:
    }
    return Center(
      child: Flexible(
        child: Text(message, 
        textAlign: TextAlign.center,
          style: TextStyle(
            color: color,

            fontWeight: FontWeight.bold,
            fontSize: 30
          ),
        ),
      ),
    );
  }

  Widget computerButton(Selection? selection) {
    String asset = "assets/default.png";
    switch (selection) {
      case Selection.pedra:
        asset = "assets/pedra.png";
        break;
      case Selection.papel:
        asset = "assets/papel.png";
        break;
      case Selection.tesoura:
        asset = "assets/tesoura.png";
        break;
      default:
    }
    return AnimatedContainer(
      width: isShrinking ? 50 : 200,
      height: isShrinking ? 50 :200,
      transformAlignment: Alignment.center,
      transform: Matrix4.rotationZ(isShrinking ? 3.14:0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage(asset)
        )
      ),
    );
  }
}

class SelectionWidget extends StatefulWidget {

  final Function(Selection) playGame;
  final Selection selection;
  final String asset;
  final Selection? playerSelection;

  const SelectionWidget({super.key, 
  required this.playGame, 
  required this.selection,
  required this.asset, 
  this.playerSelection});

  @override
  State<SelectionWidget> createState() => _SelectionWidgetState();
}

class _SelectionWidgetState extends State<SelectionWidget> {

  bool isHovering = false;
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    bool isGrown = isHovering || widget.selection == widget.playerSelection;
    double width = MediaQuery.of(context).size.width;
    double maxW = min(width * (1/3), 200);
    double minW = min(width * (1/4), 100);
    
    return InkWell(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onHover: (hovering) => setState(() {
        if (widget.playerSelection != null) {
          isHovering = false;
        } else {
          isHovering = hovering;
        }
      }),
      onTap: () {
        widget.playGame(widget.selection);
        isSelected = true;
      },
      child: AnimatedContainer(
        width: isGrown  ? maxW: minW,
        height: isGrown ? maxW: minW,
        // width: double.infinity,
        // height: double.infinity,
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isGrown ? 4 : 0),
        curve: Curves.ease,
        decoration: BoxDecoration(
          color: isGrown ? Colors.indigoAccent : Colors.transparent,
          shape: BoxShape.circle,
          // image: DecorationImage(
          //   fit: BoxFit.fill,
          //   image: AssetImage(widget.asset),
          // ),
        ),
        child: Image.asset(widget.asset),
      ),
    );
  }
}