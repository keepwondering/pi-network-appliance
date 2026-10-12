# Kids VLAN DNS through Pi-hole

Pi-hole runs on the Raspberry Pi at `192.168.0.2` using Docker host networking.
The default LAN is `192.168.0.0/24`. The proposed Kids VLAN is VLAN 30,
`192.168.30.0/24`; verify the actual UniFi network settings before deploying.

## UniFi configuration (manual; not controlled by this repository)

1. Configure Kids VLAN DHCP to advertise **only** `192.168.0.2` as DNS.
2. Allow **Kids VLAN → 192.168.0.2, TCP and UDP destination port 53**, Internal → Internal.
   Set source to the Kids network, destination to that single host, and enable return traffic.
3. Ensure the DNS allow takes precedence over any Kids-to-LAN isolation policy.
4. Block other Kids → trusted LAN access, including the Pi-hole web UI (TCP 80)
   and SSH (TCP 22). Do not rely on the DNS allow rule to provide isolation.
5. Remove unintended duplicate DNS allow policies in other zone pairs after review.
6. Check IPv6 and alternate DNS/DoH/DoT paths separately; DHCP DNS alone is not enforcement.

## Pi-hole

The Compose file sets Pi-hole v6 `FTLCONF_dns_listeningMode=ALL` so it
can answer routed clients. This is safe only when the gateway/host firewall
prevents untrusted networks from reaching DNS. Never forward TCP/UDP 53
from the public internet to this Raspberry Pi.

In the Pi-hole admin interface, create a `Kids` group and assign each
child's reserved `192.168.30.x` address. Apply curated child-appropriate
domain lists to that group. DNS logs are not a complete browsing history.

## Pre-deploy checks

```sh
ansible-playbook -i ansible/inventory.ini ansible/site.yml --syntax-check
docker compose -f ansible/roles/pihole/files/compose.yml config --quiet
```

The Compose command requires the expected environment variables; for a
local syntax check provide dummy values, never real secrets in terminal history.

## Post-deploy validation

On the Pi:

```sh
docker exec pihole pihole version
docker exec pihole grep -E 'listeningMode|upstreams' /etc/pihole/pihole.toml
sudo ufw status numbered
dig @127.0.0.1 example.com
```

On a Kids VLAN client:

```sh
dig @192.168.0.2 example.com
resolvectl status
curl --connect-timeout 3 -I http://192.168.0.2/admin/
dig @8.8.8.8 example.com +time=2 +tries=1
```

DNS via Pi-hole should succeed; the web UI should be blocked. Direct external
DNS should fail if DNS egress restrictions are configured. Confirm the Pi-hole
query log attributes the request to the individual client. Verify the default
LAN and WireGuard DNS still work.

## Follow-up hardening

- Review the existing broad UFW rules for ports 53, 80, and 22 before
  replacing them with source-scoped rules. **This PR does not change UFW**;
  changing it remotely without verified management access could lock out SSH.
- Pin a tested Pi-hole container image version instead of `latest`.
- Move credentials to Ansible Vault or a secret store; rotate any live values
  committed in plaintext or hashes.
- Review the WireGuard service separately before changing VPN behavior.
