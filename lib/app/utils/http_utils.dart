import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class HttpUtils {
  static Future<http.Response> postWithCORS(
    String url, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    
    // Prepare headers
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    // For web, we need to handle CORS differently
    if (kIsWeb) {
      try {
        // Try to make the request directly first
        final response = await http.post(
          uri,
          headers: requestHeaders,
          body: jsonEncode(body),
        );
        
        // If we get a CORS error, try with a CORS proxy
        if (response.headers['access-control-allow-origin'] == null) {
          return await _makeRequestWithCorsProxy(
            url,
            body: body,
            headers: requestHeaders,
          );
        }
        
        return response;
      } catch (e) {
        developer.log('Direct request failed, trying with CORS proxy', error: e);
        return await _makeRequestWithCorsProxy(
          url,
          body: body,
          headers: requestHeaders,
        );
      }
    }
    
    // For non-web platforms, make a normal request
    return await http.post(
      uri,
      headers: requestHeaders,
      body: jsonEncode(body),
    );
  }
  
  static Future<http.Response> _makeRequestWithCorsProxy(
    String url, {
    required Map<String, dynamic> body,
    required Map<String, String> headers,
  }) async {
    // List of CORS proxies to try
    final corsProxies = [
      'https://api.allorigins.win/raw?url=',  // Doesn't require activation
      'https://corsproxy.io/?${Uri.encodeQueryComponent('')}',  // Doesn't require activation
    ];
    
    http.Response? lastResponse;
    Exception? lastError;
    
    // Try each proxy until one works
    for (final proxy in corsProxies) {
      try {
        final proxyUrl = '$proxy$url';
        developer.log('Trying CORS proxy: $proxyUrl', name: 'HttpUtils');
        
        final proxyUri = Uri.parse(proxyUrl);
        final proxyHeaders = Map<String, String>.from(headers);
        
        // Some proxies have specific requirements
        if (proxy.contains('corsproxy.io')) {
          // For corsproxy.io, we need to include the URL as a query parameter
          final encodedUrl = Uri.encodeComponent(url);
          final proxyUri = Uri.parse('https://corsproxy.io/?$encodedUrl');
          
          lastResponse = await http.post(
            proxyUri,
            headers: proxyHeaders,
            body: jsonEncode(body),
          );
        } else {
          // For other proxies
          lastResponse = await http.post(
            proxyUri,
            headers: proxyHeaders,
            body: jsonEncode(body),
          );
        }
        
        // If we got a successful response, return it
        if (lastResponse.statusCode >= 200 && lastResponse.statusCode < 300) {
          return lastResponse;
        }
        
        developer.log('Proxy ${proxyUri.host} returned status code: ${lastResponse.statusCode}', 
            name: 'HttpUtils');
            
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        developer.log('Proxy failed: $e', name: 'HttpUtils');
        // Continue to next proxy
      }
    }
    
    // If we get here, all proxies failed
    throw lastError ?? Exception('All CORS proxies failed');
  }
}
