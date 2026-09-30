#!/bin/sh
# Run memcached's native test programs only.
#
# `make test` runs these programs and then the upstream Perl integration
# suite. The latter is not currently z/OS-compatible and may leave daemon
# processes running after testapp has printed its 56-case TAP result.
set -e

./sizes
exec ./testapp
