#!/bin/bash

echo "========================================"
echo "  Public IP Address Detection Script"
echo "========================================"
echo ""

# Method 1: Try ipify.org
echo "Method 1: Checking ipify.org..."
PUBLIC_IP=$(curl -s --max-time 10 https://api.ipify.org?format=json 2>/dev/null | grep -oP '"ip":\s*\K[^," ]+' || echo "")

if [ -n "$PUBLIC_IP" ]; then
    echo "  SUCCESS! Public IP: $PUBLIC_IP"
    echo ""
    echo "========================================"
    echo "  Your Public IP Address is:"
    echo "========================================"
    echo ""
    echo "  IP Address: $PUBLIC_IP"
    echo ""

    # Try to get location
    echo "Method 2: Getting geolocation..."
    LOCATION=$(curl -s --max-time 10 https://ipinfo.io/json 2>/dev/null)
    if [ -n "$LOCATION" ]; then
        CITY=$(echo "$LOCATION" | grep -oP '"city":\s*"\K[^"]+' 2>/dev/null)
        REGION=$(echo "$LOCATION" | grep -oP '"region":\s*"\K[^"]+' 2>/dev/null)
        COUNTRY=$(echo "$LOCATION" | grep -oP '"country":\s*"\K[^"]+' 2>/dev/null)

        if [ -n "$CITY" ]; then
            echo "  Location: $CITY, $REGION, $COUNTRY"
        fi
    fi
else
    echo "  Failed to get public IP from ipify.org"
fi

echo ""
echo "========================================"
echo ""

# Method 3: Try alternative services
echo "Method 3: Trying alternative services..."
IPFALLBACK=$(curl -s --max-time 10 https://ifconfig.me/ip 2>/dev/null | head -1)

if [ -n "$IPFALLBACK" ] && [ "$IPFALLBACK" != "$PUBLIC_IP" ]; then
    echo "  Alternative IP from ifconfig.me: $IPFALLBACK"
fi

echo ""

# Method 4: Show local network info
echo "Method 4: Your local network interfaces..."
echo ""
ip addr show 2>/dev/null | grep -A1 "inet " | grep -v "inet6" | grep -v "127.0.0.1" || echo "  Unable to retrieve local IP info (Windows?)"

echo ""

# Summary
echo "========================================"
echo "  Summary"
echo "========================================"

if [ -n "$PUBLIC_IP" ]; then
    echo "  DETECTED PUBLIC IP: $PUBLIC_IP"
else
    echo "  Unable to determine public IP address."
    echo ""
    echo "  Possible reasons:"
    echo "    - No internet connection"
    echo "    - Behind NAT (behind a router)"
    echo "    - Cloud provider metadata not accessible"
fi

echo "========================================"

echo ""
echo "For cloud providers, use their metadata service:"
echo "  AWS:    http://169.254.169.254/latest/meta-data/public-ipv4"
echo "  Azure:  http://169.254.169.254/metadata/instance/publicIPAddress?format=text"
echo "  GCP:    http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip"
echo ""
