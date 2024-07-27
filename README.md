# Nix flake for Binary Ninja
This is an unofficial, experimental Nix flake for running Binary Ninja on NixOS.

More testing is needed; currently only `x86-64_linux` is tested, and only a bit.
Additionally, more variants (e.g. an FHS variant) might be desirable.

## License

### Binary Ninja

Please note that Binary Ninja is not free software. This flake does not grant
you a license to use Binary Ninja.

When using the `binary-ninja-free` package, a copy of Binary Ninja will be
downloaded from the Vector 35 servers. Prior to using this flake, you must
agree to the
[Binary Ninja Free License terms](https://docs.binary.ninja/about/license.html#free-license).
For all other editions, you must acquire a current copy of Binary Ninja for your
platform and add it to the Nix store, using, for example, the following command:

```console
$ nix-store --add-fixed sha256 ./binary-linux-commercial.zip
```

Of course, your usage of personal, commercial and enterprise Binary Ninja is
governed by your respective agreements.

### Nix Flake

This Nix flake is in the public domain, or in jurisdictions where this is not
recognized, is available under the terms of the Unlicense. See LICENSE.md for
more information.
