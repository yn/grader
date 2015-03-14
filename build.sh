#!/bin/sh
mkdir -p build
raco exe -o build/engine src/engine.rkt
raco exe -o build/bridge --gui src/bridge.rkt
