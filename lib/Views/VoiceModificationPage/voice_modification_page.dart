import 'package:easy_localization/easy_localization.dart';
import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/voice_to_text.dart';

class VoiceModificationPage extends StatelessWidget {
  const VoiceModificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final voiceController = Provider.of<VoiceToTextController>(context);

    // Call getAvailableVoices when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      voiceController.getAvailableVoices();
    });

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Flexify.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
          ),
        ),
        title: Text(
          tr('modify_voice_settings'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('voice_model'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              // Dropdown only appears when voices are available
              voiceController.voiceModels.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : DropdownButton<String>(
                      value: voiceController.voice.isEmpty ||
                              !voiceController.voiceModels
                                  .contains(voiceController.voice)
                          ? null
                          : voiceController.voice,
                      onChanged: (newValue) {
                        if (newValue != null) {
                          voiceController.setVoice(newValue);
                        }
                      },
                      items: voiceController.voiceModels
                          .map<DropdownMenuItem<String>>((String model) {
                        return DropdownMenuItem<String>(
                          value: model,
                          child: Text(
                            model,
                            style: TextStyle(
                              color: Colors.blueGrey.shade300,
                            ),
                          ),
                        );
                      }).toList(),
                      isExpanded: true,
                      iconEnabledColor: Colors.white,
                      dropdownColor: Colors.black87,
                    ),

              SizedBox(
                height: 20.h,
              ),
              Row(
                children: [
                  Text(
                    tr('pitch'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    voiceController.pitch.toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8.h,
              ),
              Slider(
                activeColor: Colors.blueGrey,
                value: voiceController.pitch,
                min: 0.5,
                max: 2.0,
                divisions: 10,
                onChanged: (value) {
                  voiceController.setPitch(value);
                },
              ),
              SizedBox(
                height: 20.h,
              ),
              Row(
                children: [
                  Text(
                    tr('speech_rate'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    voiceController.speechRate.toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8.h,
              ),
              Slider(
                activeColor: Colors.blueGrey,
                value: voiceController.speechRate,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                onChanged: (value) {
                  voiceController.setSpeechRate(value);
                },
              ),
              // SizedBox(
              //   height: 30.h,
              // ),
              Text(
                tr('mic_duration'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      activeColor: Colors.blueGrey,
                      value: voiceController.micDuration.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 11,
                      onChanged: (value) {
                        voiceController.setMicDuration(value.toInt());
                      },
                    ),
                  ),
                  Text(
                    "${voiceController.micDuration}s",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    voiceController.previewVoice();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    tr('preview_voice'),
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
