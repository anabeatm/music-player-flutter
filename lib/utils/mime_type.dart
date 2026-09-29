String guessAudioMimeType(String? extension) {
  switch ((extension ?? '').toLowerCase()) {
    case 'wav':
      return 'audio/wav';
    case 'm4a':
      return 'audio/mp4';
    case 'ogg':
      return 'audio/ogg';
    case 'flac':
      return 'audio/flac';
    case 'mp3':
    default:
      return 'audio/mpeg';
  }
}

String guessImageMimeType(String? extension) {
  switch ((extension ?? '').toLowerCase()) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    case 'png':
    default:
      return 'image/png';
  }
}
