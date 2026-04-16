import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:vocal_lens/Helper/youtube_api_helper.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:permission_handler/permission_handler.dart';

class YoutubeController extends ChangeNotifier {
  final YoutubeService _youtubeService = YoutubeService();
  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = false;

  YoutubePlayerController? _playerController;
  bool _isAutoPlay = true;
  double _playbackSpeed = 1.0;

  List<Map<String, dynamic>> get videos => _videos;
  bool get isLoading => _isLoading;
  bool get isAutoPlay => _isAutoPlay;
  double get playbackSpeed => _playbackSpeed;
  YoutubePlayerController? get playerController => _playerController;

  Future<void> loadVideos(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _videos = await _youtubeService.searchVideos(query);
    } catch (e) {
      _videos = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void initializePlayer(String videoId) {
    _playerController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: _isAutoPlay, 
      params: const YoutubePlayerParams(
        showFullscreenButton: false,
        showVideoAnnotations: false,
        enableCaption: true,
      ),
    );
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    if (_playerController == null) return;
    speed = speed.clamp(0.25, 2.0);

    _playbackSpeed = speed;
    _playerController!.setPlaybackRate(speed);
    notifyListeners();
  }

  void toggleAutoPlay(String videoId) {
    _isAutoPlay = !_isAutoPlay;
    initializePlayer(videoId);

    notifyListeners();
  }

  Future<void> downloadAudio(String videoId) async {
    try {
      var yt = YoutubeExplode();

      // Await the stream manifest to get available streams
      var manifest = await yt.videos.streamsClient.getManifest(videoId);

      // Get highest bitrate audio-only stream
      var audioStreamInfo = manifest.audioOnly.withHighestBitrate();

      // Get the actual stream data
      var audioStream = yt.videos.streamsClient.get(audioStreamInfo);

      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        log("Storage permission denied.");
        return;
      }

      // Get storage directory
      Directory dir = await getApplicationDocumentsDirectory();
      String filePath = '${dir.path}/$videoId.mp3';

      // Save file
      File file = File(filePath);
      IOSink sink = file.openWrite();
      await sink.addStream(audioStream);
      await sink.close();

      log("Download completed: $filePath");
    } catch (e) {
      log("Error downloading audio: $e");
    }
  }

  Future<void> getDownloadedAudio() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/AJtDXIazrMo.mp3';
    File audioFile = File(filePath);

    if (await audioFile.exists()) {
      log("Audio File Path: ${audioFile.path}");
    } else {
      log("File not found!");
    }
  }

  Future<String> getDownloadPath() async {
    final directory = await getExternalStorageDirectory();
    return directory?.path ?? "";
  }

  Future<void> moveFileToDownloads() async {
  final appDir = await getApplicationDocumentsDirectory();
  final filePath = '${appDir.path}/AJtDXIazrMo.mp3';

  final downloadsDir = Directory('/storage/emulated/0/Download/');
  final newFile = File('${downloadsDir.path}/AJtDXIazrMo.mp3');

  if (await File(filePath).exists()) {
    await File(filePath).copy(newFile.path);
    log("File moved to Downloads: ${newFile.path}");
  } else {
    log("File not found!");
  }
}
}