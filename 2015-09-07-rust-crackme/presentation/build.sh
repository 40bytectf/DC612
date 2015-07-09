#!/bin/bash

echo -n "Building slides..."
multirust run nightly rustdoc slides.md -o . --html-in-header=inc/header.inc.html --markdown-no-toc
echo " Done."
