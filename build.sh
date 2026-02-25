#!/bin/bash -xe
mkdir -p builds
touch builds/.gdignore

name="$(sed -n -E -e 's/^config\/name="(.*)"$/\1/p' project.godot)"

rm -rf builds/web
mkdir -p builds/web
godot --headless --export-release Web "builds/web/$name.html" &

rm -rf builds/linux
mkdir -p builds/linux/debug
godot --headless --export-debug Linux "builds/linux/debug/$name.x86_64" &
mkdir -p builds/linux/release
godot --headless --export-release Linux "builds/linux/release/$name.x86_64" &

rm -rf builds/windows
mkdir -p builds/windows/debug
godot --headless --export-debug 'Windows Desktop' "builds/windows/debug/$name.exe" &
mkdir -p builds/windows/release
godot --headless --export-release Linux "builds/windows/release/$name.exe" &

wait
