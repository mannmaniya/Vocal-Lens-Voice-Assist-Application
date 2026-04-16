import 'package:easy_localization/easy_localization.dart';
import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/voice_to_text.dart';

class FavouriteResponsesPage extends StatelessWidget {
  const FavouriteResponsesPage({super.key});

  @override
  Widget build(BuildContext context) {
    VoiceToTextController voiceToTextController =
        Provider.of<VoiceToTextController>(context);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Flexify.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 24.sp,
          ),
        ),
        foregroundColor: Colors.white,
        title: Text(
          tr(
            "favourite_responses",
          ),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: voiceToTextController.favoritesList.isEmpty
            ? Center(
                child: Text(
                  tr(
                    "no_favorites_yet",
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: voiceToTextController.favoritesList.length,
                itemBuilder: (context, index) {
                  String favoriteResponse =
                      voiceToTextController.favoritesList[index];

                  return Slidable(
                    key: ValueKey(index),
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            voiceToTextController.deleteHistory(
                              index.toString(),
                            );
                          },
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 8,
                      color: Colors.blueGrey.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      shadowColor: Colors.black87,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                          size: 40.sp,
                        ),
                        title: Text(
                          "Favorite Response #${index + 1}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 4.h,
                            ),
                            Text(
                              favoriteResponse,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(
                              height: 8.h,
                            ),
                            Text(
                              "Date: ${DateTime.now().toString().split(' ')[0]}",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            voiceToTextController
                                .removeFromFavorites(favoriteResponse);
                          },
                        ),
                        onTap: () {},
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
