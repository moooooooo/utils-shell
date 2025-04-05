#!/bin/bash
#
# script for DaVince Rolver 19.x and 20 beta which fixes library issues.
#
#
LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libgio-2.0.so /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so /usr/lib/x86_64-linux-gnu/libglib-2.0.so" /opt/resolve/bin/resolve
