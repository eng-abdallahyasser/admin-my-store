import 'dart:async';
import 'dart:developer';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Web-specific audio helper using HTML5 Audio API
/// This provides a more reliable fallback for web deployments
class WebAudioHelper {
  html.AudioElement? _audioElement;
  bool _isInitialized = false;
  bool _isPlaying = false;

  /// Initialize the audio player with user gesture
  Future<bool> initialize() async {
    if (!kIsWeb) return false;
    
    try {
      log('Initializing WebAudioHelper...');
      
      // Create audio element with the correct asset path for web build
      _audioElement = html.AudioElement('assets/sounds/new_order.mp3');
      _audioElement!.loop = true;
      _audioElement!.volume = 0.0;
      
      // Load the audio
      _audioElement!.load();
      
      // Try to play silently to unlock autoplay
      await _audioElement!.play();
      
      _isInitialized = true;
      log('WebAudioHelper initialized successfully');
      return true;
    } catch (e, s) {
      log('Failed to initialize WebAudioHelper: $e', stackTrace: s);
      return false;
    }
  }

  /// Play the alert sound at full volume
  Future<void> play() async {
    if (!kIsWeb || !_isInitialized || _audioElement == null) {
      log('Cannot play: not initialized or not web');
      return;
    }

    try {
      _audioElement!.volume = 1.0;
      if (_audioElement!.paused) {
        await _audioElement!.play();
      }
      _isPlaying = true;
      log('WebAudioHelper: Playing sound');
    } catch (e, s) {
      log('Failed to play sound: $e', stackTrace: s);
    }
  }

  /// Stop/mute the alert sound
  Future<void> stop() async {
    if (!kIsWeb || _audioElement == null) return;

    try {
      // Keep playing but mute to maintain autoplay permission
      _audioElement!.volume = 0.0;
      _isPlaying = false;
      log('WebAudioHelper: Stopped/muted sound');
    } catch (e, s) {
      log('Failed to stop sound: $e', stackTrace: s);
    }
  }

  /// Dispose of the audio element
  void dispose() {
    try {
      _audioElement?.pause();
      _audioElement?.remove();
      _audioElement = null;
      _isInitialized = false;
      _isPlaying = false;
    } catch (e) {
      log('Error disposing WebAudioHelper: $e');
    }
  }

  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
}
