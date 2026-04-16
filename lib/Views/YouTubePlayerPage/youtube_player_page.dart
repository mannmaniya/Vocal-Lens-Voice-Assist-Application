import 'package:easy_localization/easy_localization.dart';
import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/youtube_controller.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubePlayerPage extends StatelessWidget {
  final String videoId;
  final Map<String, dynamic> videoData;

  const YoutubePlayerPage({
    super.key,
    required this.videoId,
    required this.videoData,
  });

  @override
  Widget build(BuildContext context) {
    final youtubeController = Provider.of<YoutubeController>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      youtubeController.initializePlayer(videoId);
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: youtubeController.playerController == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : YoutubePlayerScaffold(
              controller: youtubeController.playerController!,
              builder: (context, player) {
                return SafeArea(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Stack(
                            children: [
                              player,
                              _buildGradientOverlay(),
                              _buildBackButton(context),
                            ],
                          ),
                          Expanded(
                            child: _buildVideoDetails(context),
                          ),
                        ],
                      ),
                      // _buildFloatingBottomBar(context),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      height: 250.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.5),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: 10.h,
      left: 10.w,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: IconButton(
          onPressed: () => Flexify.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoDetails(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              videoData['title'] ?? 'Unknown Title',
              style: TextStyle(
                fontSize: 22.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            _buildChannelInfo(),
            SizedBox(
              height: 10.h,
            ),
            Text(
              tr('video_description'),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              videoData['description'] ?? "No description available",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[400],
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: 10.h,
            ),
            Divider(
              color: Colors.grey[800],
            ),
            _buildVideoStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 25.r,
          backgroundImage: NetworkImage(
            videoData['thumbnails']?['default']?['url'] ?? '',
          ),
        ),
        SizedBox(
          width: 12.w,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              videoData['channelTitle'] ?? 'Unknown Channel',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 4.h,
            ),
            Text(
              tr('youtube_creator'),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.remove_red_eye,
              color: Colors.white,
              size: 18.sp,
            ),
            SizedBox(
              width: 5.w,
            ),
            Text(
              '${videoData['viewCount'] ?? "0"} views',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        Text(
          videoData['publishedAt']?.toString().substring(0, 10) ?? "",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingBottomBar(BuildContext context) {
    final youtubeController = Provider.of<YoutubeController>(context);

    return Positioned(
      bottom: 20.h,
      left: 20.w,
      right: 20.w,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: 20.w,
        ),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            PopupMenuButton<double>(
              icon: Icon(
                Icons.speed,
                color: Colors.white,
                size: 26.sp,
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 0.5,
                  child: Text(
                    "0.5x",
                  ),
                ),
                const PopupMenuItem(
                  value: 1.0,
                  child: Text(
                    "1.0x (Normal)",
                  ),
                ),
                const PopupMenuItem(
                  value: 1.5,
                  child: Text(
                    "1.5x",
                  ),
                ),
                const PopupMenuItem(
                  value: 2.0,
                  child: Text(
                    "2.0x",
                  ),
                ),
              ],
              onSelected: youtubeController.setPlaybackSpeed,
            ),
            IconButton(
              icon: Icon(
                youtubeController.isAutoPlay
                    ? Icons.play_circle_fill
                    : Icons.pause_circle_filled,
                color: youtubeController.isAutoPlay
                    ? Colors.greenAccent
                    : Colors.redAccent,
              ),
              onPressed: () => youtubeController.toggleAutoPlay(videoId),
            ),
            IconButton(
              icon: const Icon(
                Icons.download,
                color: Colors.white,
              ),
              onPressed: () => youtubeController.downloadAudio(videoId),
            ),
          ],
        ),
      ),
    );
  }
}
