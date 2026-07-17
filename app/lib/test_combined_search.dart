import 'package:http/http.dart' as http;

Future<void> testUnsplashCurl() async {
  final url = Uri.parse("https://unsplash.com/s/photos/oats");
  try {
    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'curl/7.64.1',
      },
    );
    print("Unsplash (curl) status: ${response.statusCode}, length: ${response.body.length}");
    final idx = response.body.indexOf("images.unsplash.com/photo-");
    if (idx != -1) {
      print("Found Unsplash image: ${response.body.substring(idx, idx + 100)}");
    }
  } catch (e) {
    print("Error Unsplash: $e");
  }
}

Future<void> testDuckDuckGoImages() async {
  final url = Uri.parse("https://html.duckduckgo.com/html/?q=oats&iax=images&ia=images");
  try {
    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
      },
    );
    print("DDG Images status: ${response.statusCode}, length: ${response.body.length}");
    final idx = response.body.indexOf("tse");
    if (idx != -1) {
      print("Found DDG image: ${response.body.substring(idx - 50, idx + 150)}");
    }
  } catch (e) {
    print("Error DDG: $e");
  }
}

void main() async {
  await testUnsplashCurl();
  await testDuckDuckGoImages();
}
