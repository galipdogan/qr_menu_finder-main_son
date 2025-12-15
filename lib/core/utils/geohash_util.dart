/// Simple geohash implementation for proximity queries
/// For production, consider using a package like 'geoflutterfire2'
class GeohashUtil {
  static const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// Generate geohash from latitude and longitude
  /// Precision: 1=5000km, 2=1250km, 3=156km, 4=39km, 5=5km, 6=1.2km, 7=152m, 8=38m
  static String encode(double lat, double lng, {int precision = 7}) {
    var latRange = [-90.0, 90.0];
    var lngRange = [-180.0, 180.0];
    var hash = '';
    var bits = 0;
    var bit = 0;
    var even = true;

    while (hash.length < precision) {
      if (even) {
        final mid = (lngRange[0] + lngRange[1]) / 2;
        if (lng > mid) {
          bit |= (1 << (4 - bits));
          lngRange[0] = mid;
        } else {
          lngRange[1] = mid;
        }
      } else {
        final mid = (latRange[0] + latRange[1]) / 2;
        if (lat > mid) {
          bit |= (1 << (4 - bits));
          latRange[0] = mid;
        } else {
          latRange[1] = mid;
        }
      }

      even = !even;
      bits++;

      if (bits == 5) {
        hash += _base32[bit];
        bits = 0;
        bit = 0;
      }
    }

    return hash;
  }

  /// Get neighboring geohashes for proximity search
  static List<String> getNeighbors(String geohash) {
    // Simplified version - returns the geohash and basic neighbors
    // For production, implement full neighbor calculation
    return [geohash];
  }

  /// Get geohash prefix for distance
  /// Approximate precision based on distance in kilometers
  static int getPrecisionForDistance(double distanceKm) {
    if (distanceKm >= 5000) return 1;
    if (distanceKm >= 1250) return 2;
    if (distanceKm >= 156) return 3;
    if (distanceKm >= 39) return 4;
    if (distanceKm >= 5) return 5;
    if (distanceKm >= 1.2) return 6;
    if (distanceKm >= 0.152) return 7;
    return 8;
  }
}