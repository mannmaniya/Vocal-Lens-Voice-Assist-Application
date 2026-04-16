import 'package:easy_localization/easy_localization.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/how_to_use_controller.dart';
import 'package:vocal_lens/Model/feature_model.dart';

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final howToUseProvider = Provider.of<HowToUseProvider>(context);
    List<FeatureModel> features = howToUseProvider.features;

    return FeatureDiscovery(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Flexify.back();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
            ),
          ),
          title: Text(
            tr(
              "how_to_use",
            ),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              onPressed: howToUseProvider.togglePlayPause,
              icon: Icon(
                howToUseProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 30.sp,
              ),
            ),
            SizedBox(
              width: 5.w,
            ),
          ],
          backgroundColor: Colors.blueGrey.shade900,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: features.map((feature) {
                return _buildFeatureStep(
                  context,
                  feature,
                  howToUseProvider,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureStep(
      BuildContext context, FeatureModel feature, HowToUseProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          int index = provider.features.indexOf(feature);
          if (index != -1) {
            provider.speakFeature(index);
          }
        },
        child: DescribedFeatureOverlay(
          featureId: feature.featureId,
          tapTarget: Icon(
            feature.icon,
            color: Colors.white,
          ),
          title: Text(
            feature.title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          description: Text(
            feature.description,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          backgroundColor: Colors.blueGrey.shade800,
          targetColor: Colors.white,
          child: ListTile(
            leading: Icon(
              feature.icon,
              color: Colors.white,
            ),
            title: Text(
              feature.title,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              feature.description,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
