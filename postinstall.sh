#!/bin/bash

set -e
set -u
set -o pipefail

TARGET=esySolveCudfCommand.exe

case $(uname) in
  Darwin*)
    mv esySolveCudfCommandDarwin.exe "$TARGET"
    ;;
  Linux*)
    mv esySolveCudfCommandLinux.exe "$TARGET"
    ;;
  *)
    echo "Unsupported operating system $(uname), exiting...";
    exit 1
    ;;
esac

chmod +x "$TARGET"
