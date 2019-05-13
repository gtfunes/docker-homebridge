#!/bin/sh

#
# Docker Homebridge Custom Startup Script - oznu/homebridge
#
# This script can be used to customise the environment and will be executed as
# the root user each time the container starts.
#
# If using this to install plugins DO NOT use the global flag (-g).
#
# Example installing homebridge plugin:
#
# npm install homebridge-hue
#
# Example installing packages using default image (Alpine Linux):
#
# apk add --no-cache ffmpeg ffmpeg-libs libpcap-dev
#
# If you're running a debian based version of this container please use apt-get to install packages.
#

npm --no-update-notifier install --unsafe-perm --save homebridge-automation-chromecast homebridge-camera-ffmpeg-omx homebridge-hue homebridge-people homebridge-plex-v2 homebridge-samsung-tizen

apk add --no-cache ffmpeg ffmpeg-libs
