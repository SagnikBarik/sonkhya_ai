import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:whiteboard/whiteboard.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:choice/choice.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int result = -1;
  double resultProbability = -1.0;
  final WhiteBoardController _whiteBoardController = WhiteBoardController();
  
  final List<String> models = [
    'CNN',
    'ANN',
  ];
  String? selectedModel = 'CNN';
  void setSelectedValue(String? value) {
    setState(() => selectedModel = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.all(5.0),
          child: Text(
            'Sonkhya.AI',
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const Text(
                    'Choose Model: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  Choice<String>.inline(
                    clearable: false,
                    value: ChoiceSingle.value(selectedModel),
                    onChanged: ChoiceSingle.onChanged(setSelectedValue),
                    itemCount: models.length,
                    itemBuilder: (state, i) {
                      return ChoiceChip(
                        selected: state.selected(models[i]),
                        onSelected: state.onSelected(models[i]),
                        label: Text(models[i]),
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                      );
                    },
                    listBuilder: ChoiceList.createScrollable(
                      spacing: 15,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  color: Colors.black,
                  height: MediaQuery.of(context).size.height * 0.55,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: WhiteBoard(
                          controller: _whiteBoardController,
                          backgroundColor: Colors.black87,
                          strokeColor: Colors.white,
                          strokeWidth: 20,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        result == -1 ? "" : 'Prediction Result: $result',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        resultProbability == -1.0
                            ? ""
                            : 'Confidence: ${resultProbability.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      onTap: () {
                        _whiteBoardController.clear();
                        setState(() {
                          result = -1;
                          resultProbability = -1.0;
                        });
                      },
                      child: Container(
                        color: const Color.fromARGB(255, 254, 78, 44),
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: const Icon(Icons.delete_rounded,
                            color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      onTap: () async {
                        try {
                          final imageBytes = await _whiteBoardController
                              .convertToImage(format: ImageByteFormat.png);
                          img.Image image =
                              img.decodeImage(imageBytes.buffer.asUint8List())!;
                          image = img.grayscale(image);
                          image = img.copyResize(image, width: 28, height: 28);
                          List<List<List<double>>> normalizedImage = [];
                          for (int i = 0; i < image.height; i++) {
                            List<List<double>> row = [];
                            for (int j = 0; j < image.width; j++) {
                              var pixel = image.getPixel(j, i);
                              row.add([img.getLuminance(pixel) / 255.0]);
                            }
                            normalizedImage.add(row);
                          }
                          var inputBuffer = List.from([normalizedImage]);
                          var outputBuffer =
                              List.filled(10, 0.0).reshape([1, 10]);
                          final tfl.Interpreter interpreter;
                          if (selectedModel == 'CNN') {
                            interpreter = await tfl.Interpreter.fromAsset(
                                'assets/cnn_model.tflite');
                          } else if (selectedModel == 'ANN') {
                            interpreter = await tfl.Interpreter.fromAsset(
                                'assets/ann_model.tflite');
                          } else {
                            throw Exception('Model not selected');
                          }
                          interpreter.run(inputBuffer, outputBuffer);
                          // Extract the prediction
                          int predictedDigit = 0;
                          for (var i = 0; i < 10; i++) {
                            if (outputBuffer[0][i] >
                                outputBuffer[0][predictedDigit]) {
                              predictedDigit = i;
                            }
                          }
                          setState(() {
                            result = predictedDigit;
                            resultProbability =
                                outputBuffer[0][predictedDigit] * 100;
                          });
                          print(resultProbability);
                        } catch (e) {
                          print("Error occurred: $e");
                        }
                      },
                      child: Container(
                        color: const Color.fromARGB(255, 0, 212, 152),
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Predict',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 21),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'This app uses custom AI model to predict handwritten digits. While accurate, the model may occasionally make errors. Please verify the results independently.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
