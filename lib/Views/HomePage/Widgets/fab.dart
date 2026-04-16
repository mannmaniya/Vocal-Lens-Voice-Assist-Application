import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:vocal_lens/Controllers/voice_to_text.dart';
import 'package:vocal_lens/Controllers/position_controller.dart';

Widget floatingButton() {
  return Consumer2<VoiceToTextController, PositionController>(
    builder: (context, voiceToTextController, positionController, _) {
      return Stack(
        children: [
          Positioned(
            left: positionController.position.dx,
            top: positionController.position.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                positionController.updatePosition(
                    details.localPosition, context);
              },
              child: Draggable(
                feedback: GlowContainer(
                  shape: BoxShape.circle,
                  glowColor: voiceToTextController.isListening
                      ? Colors.blue
                      : Colors.transparent,
                  blurRadius: voiceToTextController.isListening ? 30 : 0,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueGrey.shade600,
                      boxShadow: voiceToTextController.isListening
                          ? [
                              const BoxShadow(
                                color: Colors.blue,
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ]
                          : [],
                    ),
                    child: FloatingActionButton(
                      onPressed: () async {
                        voiceToTextController.toggleListening();

                        log("Waiting for speech-to-text to update...");

                        await Future.delayed(
                          const Duration(
                            seconds: 2,
                          ),
                        );

                        String recognizedText =
                            voiceToTextController.text.trim();
                        log("Final speech-to-text result: $recognizedText");

                        if (!voiceToTextController.isListening &&
                            recognizedText.isNotEmpty) {
                          voiceToTextController
                              .handleVoiceCommands(recognizedText);
                        } else {
                          log("No valid command recognized.");
                        }
                      },
                      backgroundColor: Colors.blueGrey.shade600,
                      child: Icon(
                        voiceToTextController.isListening
                            ? Icons.mic
                            : Icons.mic_off,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Container(),
                onDragEnd: (details) {
                  positionController.updatePosition(details.offset, context);
                },
                child: GlowContainer(
                  shape: BoxShape.circle,
                  glowColor: voiceToTextController.isListening
                      ? Colors.blue
                      : Colors.transparent,
                  blurRadius: voiceToTextController.isListening ? 30 : 0,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueGrey.shade600,
                      boxShadow: voiceToTextController.isListening
                          ? [
                              const BoxShadow(
                                color: Colors.blue,
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ]
                          : [],
                    ),
                    child: FloatingActionButton(
                      onPressed: () {
                        // Start/Stop voice recording when pressed
                        voiceToTextController.toggleListening();
                      },
                      backgroundColor: Colors.blueGrey.shade600,
                      child: Icon(
                        voiceToTextController.isListening
                            ? Icons.mic_off
                            : Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
