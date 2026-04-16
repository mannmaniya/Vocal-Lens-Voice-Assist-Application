import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/youtube_controller.dart';

import '../../../YouTubePlayerPage/youtube_player_page.dart';

Widget youTubePageView(BuildContext context) {
  final youtubeController = Provider.of<YoutubeController>(context);
  final TextEditingController searchController = TextEditingController();

  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 16.0,
    ),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.blueGrey.shade900,
          Colors.black,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Column(
      children: [
        Card(
          elevation: 8,
          color: Colors.blueGrey.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: searchController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search videos",
                      hintStyle: const TextStyle(
                        color: Colors.white70,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.blueGrey.shade700,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8.w,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    youtubeController.loadVideos(
                      searchController.text,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 12.h,
        ),
        Expanded(
          child: youtubeController.isLoading
              ? const Center(child: CircularProgressIndicator())
              : youtubeController.videos.isEmpty
                  ? const Center(
                      child: Text(
                        "Search to access Videos",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: youtubeController.videos.length,
                      itemBuilder: (context, index) {
                        final video = youtubeController.videos[index];
                        return Card(
                          elevation: 6,
                          color: Colors.blueGrey.shade800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12.0),
                            leading: Container(
                              width: 60.w,
                              height: 60.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    video["thumbnails"]["high"]["url"],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              video["title"],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            subtitle: Text(
                              video["channelTitle"],
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14.sp,
                              ),
                            ),
                            onTap: () {
                              Flexify.go(
                                YoutubePlayerPage(
                                  videoId: video["videoId"],
                                  videoData: video,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    ),
  );
}
