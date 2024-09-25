# fujinet-apple-clock-driver

SmartPort clock driver for apple using FujiNet clock device

## building

To build the application ensure you have the correct compiler/linker for your platform (e.g. cc65), and
make on your path, then simply run make.

```shell
# to clean all artifacts, run this on its own
make clean

# to generate the application for all targets
make release

# to generate a "disk" (e.g. PO/ATR/D64)
make disk
```

As per normal cc65 rules, you can add `TARGETS=...` value to the command to only affect the named target(s) if you
are building a cross compiled application:

```shell
# just the apple2enh, and c64 targets
make TARGETS="apple2enh c64" release
```

The default list of targets can be edit in [Makefile](Makefile). Remove any entries for targets you do not
wish to build.
