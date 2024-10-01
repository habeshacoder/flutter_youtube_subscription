import 'package:myappstaked/ui/views/youtube/player_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'youtube_viewmodel.dart';

class YoutubeView extends StackedView<YoutubeViewModel> {
  const YoutubeView({Key? key}) : super(key: key);
  @override
  Widget builder(
    BuildContext context,
    YoutubeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Youtube"),
      ),
      body: ListView.builder(
        itemCount: viewModel.videoUrls.length,
        itemBuilder: (context, index) {
          final videoID =
              YoutubePlayer.convertUrlToId(viewModel.videoUrls[index]);
          return InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PLayerView(videoId: videoID)));
              },
              child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  child: Image.network(
                      YoutubePlayer.getThumbnail(videoId: videoID!))));
        },
      ),
    );
  }

  Widget thubmNail() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(10),
      color: Colors.blue,
      child: const Center(
        child: Text("THUMBNAIL"),
      ),
    );
  }

  @override
  YoutubeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      YoutubeViewModel();
}
