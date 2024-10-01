import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:googleapis/youtube/v3.dart' as youtube;
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final AuthService authService = AuthService();
String? displayName = '';
String? email = '';
String? photoUrl = '';
String? id = '';
String? accessToken = '';
String? channelId = '';
bool loading = false;
const String apiKey = 'AIzaSyDs1zX0vZ3fiKW23hpyu28txlcspU8m8vU';
const YOUR_CLIENT_ID =
    '564815606746-9f11j940chlqpg4i7g3tigcmc3dqo7ej.apps.googleusercontent.com';

class PLayerView extends StatefulWidget {
  const PLayerView({Key? key, required this.videoId}) : super(key: key);
  final dynamic videoId;
  @override
  State<PLayerView> createState() => _PLayer_ViewState();
}

class _PLayer_ViewState extends State<PLayerView> {
  bool isLoggedIn = false;
  bool isSubscribed = false;
  late final YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: widget.videoId,
    flags: const YoutubePlayerFlags(
      autoPlay: true,
      mute: false,
    ),
  );
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isUserSubscribed();
    setState(() {
      loading = false;
    });
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          authService.signOut();
          // await authService.signOut();
          setState(() {
            isLoggedIn = false;
            displayName = null;
            email = null;
            photoUrl = null;
            id = null;
            accessToken = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('You are logged out'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ));
        },
        child: const Text('Log out'),
      ),
      appBar: AppBar(title: const Text("Player")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YoutubePlayer(controller: _controller),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: isSubscribed ? null : _handleSubscribe,
                  child: loading
                      ? const CircularProgressIndicator()
                      : Text(isSubscribed ? 'Subscribed' : 'Subscribe'),
                ),
              ],
            ),
            Text('Name: ${displayName ?? ''}'),
            Text('Email: ${email ?? ''}'),
            Text('Photo URL: ${photoUrl ?? ''}'),
            Text('ID: ${id ?? ''}'),
            Text('Access Token:\n ${accessToken ?? ''}'),
          ],
        ),
      ),
    );
  }

  void _handleSubscribe() async {
    if (!isLoggedIn) {
      await _loginToYouTube();
    }
    await _isUserSubscribed();
    setState(() {
      loading = false;
    });
    if (!isSubscribed) {
      await _subscribeToChannel();
    }
  }

  Future<String?> getChannelId() async {
    final url =
        'https://www.googleapis.com/youtube/v3/videos?part=snippet&id=${widget.videoId}&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Check if items are present
      if (data['items'] != null && data['items'].isNotEmpty) {
        // Get the channel ID from the snippet
        channelId = data['items'][0]['snippet']['channelId'];
        return channelId;
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  Future<void> _loginToYouTube() async {
    final googleSignInAccount = await authService.signIn();
    dynamic googleSignInAuthentication =
        await googleSignInAccount.authentication;
    setState(() {
      displayName = googleSignInAccount.displayName;
      email = googleSignInAccount.email;
      photoUrl = googleSignInAccount.photoUrl;
      id = googleSignInAccount.id;
      accessToken = googleSignInAuthentication.accessToken;
      isLoggedIn = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('signing is done'),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }

  Future<void> _isUserSubscribed() async {
    setState(() {
      loading = true;
    });
    channelId = await getChannelId();
    final client = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken(
          'Bearer',
          accessToken!,
          DateTime.now().add(const Duration(hours: 1)).toUtc(),
        ),
        null,
        ['https://www.googleapis.com/auth/youtube.force-ssl'],
      ),
    );
    // Instantiate the YouTube API
    final youtubeApi = youtube.YouTubeApi(client);
    try {
      // Retrieve the user's subscriptions
      final subscriptionsList = await youtubeApi.subscriptions.list(
        ['snippet'],
        mine: true, // Adjust as needed
      );
      // Check if the specified channelId is in the user's subscriptions
      bool isSubscribed = subscriptionsList.items!.any(
        (subscription) =>
            subscription.snippet!.resourceId!.channelId == channelId,
      );
      if (isSubscribed) {
        setState(() {
          isSubscribed = true;
          loading = false;
        });
      }
    } catch (e) {
      // Assume not subscribed on error
      setState(() {
        loading = false;
      });
    } finally {
      // Close the client
      setState(() {
        loading = false;
      });
      client.close();
    }
  }

  Future<void> _subscribeToChannel() async {
    final value = await getChannelId();
    String channelId = value!;
    final client = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken(
          'Bearer',
          accessToken!,
          DateTime.now().add(const Duration(hours: 1)).toUtc(),
        ),
        null,
        [
          'https://www.googleapis.com/auth/youtube.force-ssl',
          youtube.YouTubeApi.youtubeForceSslScope,
          youtube.YouTubeApi.youtubeForceSslScope,
        ],
      ),
    );
    // Instantiate the YouTube API
    final youtubeApi = youtube.YouTubeApi(client);
    // Create the subscription object
    final subscription = youtube.Subscription(
      snippet: youtube.SubscriptionSnippet(
        resourceId: youtube.ResourceId(
          kind: 'youtube#channel',
          channelId: channelId,
        ),
      ),
    );
    try {
      // Subscribe to the channel
      final subscriptionResponse =
          await youtubeApi.subscriptions.insert(subscription, ['snippet']);
      if (subscriptionResponse.id != null &&
          subscriptionResponse.snippet != null) {
        setState(() {
          isSubscribed = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Successfully subscribed to the channel, ${subscriptionResponse.id}'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Failed to subscribe to the channel'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ));
      }
    } catch (e) {
      // Handle errors
    } finally {
      // Close the client
      client.close();
    }
  }
}

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'openid',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/youtube.force-ssl',
    ],
  );

  Future<dynamic> signIn() async {
    GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
    if (googleSignInAccount != null) {
      return googleSignInAccount;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
