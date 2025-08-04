import 'package:flutter/foundation.dart';
import 'package:multicast_dns/multicast_dns.dart';

class MdnsServiceDiscovery {
  final String serviceType = '_myapp111._tcp.local';

  Future<String?> discoverHostAndPort() async {
    final MDnsClient client = MDnsClient();
    try {
      await client.start();

      // Step 1: Look up PTR record for the service
      final ptrRecords = await client
          .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(serviceType))
          .toList();

      if (ptrRecords.isEmpty) {
        debugPrint('No mDNS PTR records found.');
        return null;
      }

      for (final ptr in ptrRecords) {
        // Step 2: Get SRV record (host and port)
        final srvRecords = await client
            .lookup<SrvResourceRecord>(ResourceRecordQuery.service(ptr.domainName))
            .toList();

        for (final srv in srvRecords) {
          // Step 3: Get A record (IPv4 address)
          final ipRecords = await client
              .lookup<IPAddressResourceRecord>(ResourceRecordQuery.addressIPv4(srv.target))
              .toList();

          if (ipRecords.isNotEmpty) {
            final ip = ipRecords.first.address.address;
            final port = srv.port;
            final url = 'http://$ip:$port';
            debugPrint('✅ Discovered service: $url');
             client.stop();
            return url;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ mDNS discovery failed: $e');
    } finally {
      client.stop();
    }
    return null;
  }
}
