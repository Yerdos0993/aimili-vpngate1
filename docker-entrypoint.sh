#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: AimiliVPN must run as root so OpenVPN can create and manage TUN devices." >&2
    exit 1
fi

if [ ! -c /dev/net/tun ]; then
    echo "ERROR: /dev/net/tun is unavailable." >&2
    echo "Start the container with --device=/dev/net/tun and --cap-add=NET_ADMIN." >&2
    exit 1
fi

if [ ! -r /dev/net/tun ] || [ ! -w /dev/net/tun ]; then
    echo "ERROR: /dev/net/tun is not readable and writable inside the container." >&2
    exit 1
fi

mkdir -p "${VPNGATE_DATA_DIR:-/data}"

exec "$@"
