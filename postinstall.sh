#!/bin/bash

set -e
set -u
set -o pipefail

TARGET=esySolveCommand.exe

case $(uname) in
  Darwin*)
    mv esySolveCommandDarwin.exe "$TARGET"
    ;;
  Linux*)
    mv esySolveCommandDarwin.exe "$TARGET"
    ;;
  *)
    echo "Unsupported operating system $(uname), exiting...";
    exit 1
    ;;
esac

chmod +x "$TARGET"
