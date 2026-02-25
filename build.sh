#!/bin/bash -xe
mkdir -p builds
touch builds/.gdignore

name="$(sed -n -E -e 's/^config\/name="(.*)"$/\1/p' project.godot)"

rm -rf builds/web
mkdir -p builds/web
( cd builds/web && ln -sf "$name.html" index.html )
godot --headless --export-release Web "builds/web/$name.html" &

rm -rf builds/linux
mkdir -p builds/linux/debug
godot --headless --export-debug Linux "builds/linux/debug/$name.x86_64" &
godot --headless --export-release Linux "builds/linux/$name.x86_64" &

rm -rf builds/windows
mkdir -p builds/windows/debug
godot --headless --export-debug 'Windows Desktop' "builds/windows/debug/$name.exe" &
godot --headless --export-release 'Windows Desktop' "builds/windows/$name.exe" &

mkdir -p builds/macos
godot --headless --export-release macOS "builds/macos/$name.app" &

wait
