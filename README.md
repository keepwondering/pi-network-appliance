# Pi Network Appliance (Pi-hole + WireGuard)

This repo deploys a Raspberry Pi as a "boring reliable" network appliance:
- Pi-hole (DNS + ad blocking)
- WireGuard VPN (via wg-easy)

## Requirements
- You can SSH into the Pi (Debian Trixie Lite)
- The Pi has a static DHCP reservation or static IP (recommended)

## Quick start

1) Edit `ansible/inventory.ini` and set your Pi IP + SSH user.

2) Deploy:

```sh
make deploy
```