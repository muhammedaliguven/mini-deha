class VideoModel {
  final String id;
  final String title;
  final String youtubeId;
  final String limit; // e.g., "10:00" or just minutes
  final bool isFree;

  VideoModel({
    required this.id,
    required this.title,
    required this.youtubeId,
    required this.limit,
    this.isFree = false,
  });
}
