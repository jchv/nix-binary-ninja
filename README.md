# Nix flake for Binary Ninja
This is an unofficial, experimental Nix flake for running Binary Ninja on NixOS.

More testing is needed; currently only `x86-64_linux` is tested, and only a bit.
Additionally, more variants (e.g. an FHS variant) might be desirable.

## Usage

### Run directly

You can run Binary Ninja directly from this flake:

```console
nix run github:jchv/nix-binary-ninja
```

> [!IMPORTANT]
> The experimental features `flakes` and `nix-command` must be enabled for this to succeed.
> For more information, see [Flakes on NixOS Wiki](https://nixos.wiki/wiki/Flakes).

If you want to run a specific edition, you can select an attribute like so:

```console
nix run github:jchv/nix-binary-ninja#binary-ninja-free-wayland
```

For a list of available package attributes, see the [Packages section](#Packages).

### NixOS module

To include Binary Ninja in your NixOS system using this flake, follow these steps:

 1. **Add this flake to your NixOS configuration flake's inputs:**

    ```nix
    {
      inputs = {
        nixpkgs = { ... };

        # This is what you will want to add.
        binaryninja = {
          url = "github:jchv/nix-binary-ninja";

          # Optional, but recommended.
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    ```

 2. **Include the NixOS module in your NixOS system:**

    ```nix
    {
      ...
      # You will need to add a corresponding `binaryninja` parameter to your
      # `outputs` function.
      outputs = { nixpkgs, binaryninja, ... }:
      {
        nixosConfigurations.myMachine = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ...

            # Then, you'll need to add the module itself.
            binaryninja.nixosModules.binaryninja
          ];
        }
      }
    }
    ```

    This will add new options you can use in your NixOS configuration.

 3. **Enable Binary Ninja in your NixOS configuration:**

    This can go in any NixOS configuration module imported by your configuration:

    ```nix
    {
      programs.binary-ninja.enable = true;
    }
    ```

    If you want to use a specific version, you can select this using `programs.binary-ninja.package`:

    ```nix
    { pkgs, ... }: {
      programs.binary-ninja = {
        enable = true;
        package = pkgs.binary-ninja-free-wayland;
      }
    }
    ```

    For a list of available package attributes, see the [Packages section](#Packages).

 4. **Add the installer to the nix-store, if not using the free version:**

    ```bash
    nix-store --add-fixed sha256 <path-to-installer>.zip
    ```

    You can get a copy of the latest release using your registered e-mail address [here](https://binary.ninja/recover/).

    If you want, it is possible to include a copy of Binary Ninja in your NixOS configuration to avoid this step.
    If you choose to do this, please be mindful to not accidentally leak your copy of Binary Ninja.

    To do this, you need to override the Binary Ninja package, like this:

    ```nix
    { pkgs, ... }: {
      programs.binary-ninja = {
        enable = true;
        package = pkgs.binary-ninja-personal-wayland.override {
          # The path of the filename here should be relative to the Nix file
          # it's written in.
          overrideSource = ./binaryninja_personal_linux.zip;
        };
      }
    }
    ```

## Packages
The following package attributes are available:

- `binary-ninja-free`
- `binary-ninja-personal`
- `binary-ninja-commercial`
- `binary-ninja-ultimate`
- `binary-ninja-free-wayland`
- `binary-ninja-personal-wayland`
- `binary-ninja-commercial-wayland`
- `binary-ninja-ultimate-wayland`

For the free version, please see the License section.

For other versions, note that you will need to provide the latest installer.

The `-wayland` variants will force Binary Ninja to use the Wayland window
system. This comes with some caveats and is not recommended under Gnome. See the
[Binary Ninja troubleshooting section on Wayland](https://docs.binary.ninja/guide/troubleshooting.html#wayland)
for more information.

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

Of course, your usage of personal, commercial and ultimate Binary Ninja is
governed by your respective agreements.

### Nix Flake

This Nix flake is in the public domain, or in jurisdictions where this is not
recognized, is available under the terms of the Unlicense. See LICENSE.md for
more information.
