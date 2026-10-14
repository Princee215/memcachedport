# Memcached port for z/OS

This is the [zopen community](https://github.com/zopencommunity) port of
[memcached](https://github.com/memcached/memcached) (1.6.45) to z/OS Open
Tools. memcached is a high-performance, in-memory key-value cache.

## Installing

Once the port is published, install it with the zopen package manager:

```bash
zopen install memcached
```

## Building from source

```bash
git clone https://github.com/zopencommunity/memcachedport.git
cd memcachedport
zopen build -v
```

The build clones upstream memcached, applies the patches in `patches/`, then
runs bootstrap, configure, build and the check phase.

Build dependencies: libevent, make, automake, autoconf, m4, pkgconfig, bash,
grep, perl. Runtime dependency: libevent.

## Running

Start the server on a Unix domain socket:

```bash
memcached -s /tmp/memcached.sock -a 700 -U 0 -d
```

Quick check from Perl:

```bash
perl -MIO::Socket::UNIX -e '$s=IO::Socket::UNIX->new(Peer=>"/tmp/memcached.sock") or die "$!\n"; $s->autoflush(1); print $s "version\r\n"; print scalar(<$s>);'
```

Expected output: `VERSION 1.6.45`

TCP also works (`memcached -p 11211`), as long as the port is free and not
reserved in your system's TCP/IP profile.

## What this port changes

Patches in `patches/` are applied on top of upstream:

| Patch | Purpose |
|-------|---------|
| `timedrun.c.patch` | z/OS has no `sysexits.h`; defines `EX_OSERR` / `EX_SOFTWARE` under `__MVS__` |
| `util.h.patch` | adds the `<time.h>` include required on z/OS |
| `memcached.c.patch` | z/OS portability fix |
| `testapp.c.patch` | z/OS fixes for the native test program |

## Testing

`zopen build` runs the check phase through `run-tests.sh`, which executes
memcached's native `testapp` suite (56 TAP tests covering cache logic, string
parsing, CRC32 and the binary protocol). `buildenv` parses the TAP output and
reports any `not ok` line as a failure.

### Known limitations

The upstream Perl integration suite under `t/` is **not** part of the check
phase. On z/OS it currently shows two problems:

- Deliberately invalid CLI arguments (for example `-l fooble` in
  `t/00-startup.t`) make memcached hang instead of exiting with an error.
- Tests that pass extstore suboptions (`extstore-*`, `chunked-*`,
  `conn-limits.t`, `dyn-maxbytes.t`) fail with `Illegal suboption ""`.

Contributions that fix these are welcome.

## License

memcached is licensed under the BSD 3-clause license. See `LICENSE`.
