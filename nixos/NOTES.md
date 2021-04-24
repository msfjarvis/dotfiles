# Notes on NixOS usage for a future me, and probably other people.

Using NixOS is not straightforward, or simple. It's an ordeal to say the least, and a massive pain in the ass if we're being frank. But its premise is very interesting, so we shall put up with this atrocity for the sake of science and sanity. Here's some things that were non-obvious and have been accordingly been resolved by me, documented for posterity.

## Running executables from the interwebs

The first thing you'll find is that simply downloading and running a 'static' executable will not work at all. You will receive errors of this sort:

```
adb: No such file or directory
```

*Annoying*. Also fixable. Sort of. The root of this problem is that most distros have their dynamic linker at `/lib/ld-linux-x86-64.so.2`, and traditional static builds will use that as the interpreter.

NixOS does not conform to this, and instead hosts it within the `glibc` package's `lib` directory. Now, the problem arises: how do I tell my binary that's where the linker it needs is? Turns out, NixOS solved that as well! They created a tool called `patchelf` that can perform multiple transformations on ELF binaries including setting their interpreter -- perfect for what we need.

This is a bit of a hack, but that's how I did it.

```
patchelf --set-interpreter "$(nix eval nixpkgs.glibc.outPath | sed 's/"//g')/lib/ld-linux-x86-64.so.2" $(command -v adb)
```

This first uses the `nix` package manager's `eval` option to get the directory for glibc, then strips the quotes from that output, and tacks on the ld path at the end. Then it is all passsed to `patchelf` which sets it as the interperter of whatever binary is provided, in my case, the `adb` binary from Google.

### Caveats with this approach

- Will need to be repeated for each binary
- Will need to be repeated post a glibc update
- Will need to be repeated post binary update

## Updating a package that sources from GitHub

Throughout the [nixpkgs](https://github.com/NixOS/nixpkgs) repository you'll notice a lot of package definitions containing a closure looking something like this:

```nix
src = fetchFromGitHub {
  owner = "tomaspinho";
  repo = "rtl8821ce";
  rev = "ab6154e150bbc7d12b0525d4cc1298ae196e45de";
  sha256 = "1my0hidqnv4s7hi5897m81pq0sjw05np0g27hlkg9fwb83b5kzsg";
};
```

this is not very well documented and thus fields like `sha256` can be a pain to get right when updating a package. `nix-prefetch-url` to the rescue!

```bash
$ nix-prefetch-url --type sha256 --unpack https://github.com/tomaspinho/rtl8821ce/archive/ab6154e150bbc7d12b0525d4cc1298ae196e45de.tar.gz
1my0hidqnv4s7hi5897m81pq0sjw05np0g27hlkg9fwb83b5kzsg
```

Thus, updating the package becomes rather easy. A diff should look like this

```diff
diff --git a/pkgs/os-specific/linux/rtl8821ce/default.nix b/pkgs/os-specific/linux/rtl8821ce/default.nix
index 4be462991223..554b578308e7 100644
--- a/pkgs/os-specific/linux/rtl8821ce/default.nix
+++ b/pkgs/os-specific/linux/rtl8821ce/default.nix
@@ -6,8 +6,8 @@ stdenv.mkDerivation rec {
   src = fetchFromGitHub {
     owner = "tomaspinho";
     repo = "rtl8821ce";
-    rev = "ab6154e150bbc7d12b0525d4cc1298ae196e45de";
-    sha256 = "1my0hidqnv4s7hi5897m81pq0sjw05np0g27hlkg9fwb83b5kzsg";
+    rev = "69765eb288a8dfad3b055b906760b53e02ab1dea";
+    sha256 = "17jiw25k74kv5lnvgycvj2g1n06hbrpjz6p4znk4a62g136rhn4s";
   };
 
   hardeningDisable = [ "pic" ];
```

## Diffing between home-manager generations

`nix-store` lets you dump your entire Nix package tree per-generation so it is relatively easy to diff between two of them. Use `home-manager generations` to list your currently installed generations:

```shell
$ home-manager generations
2021-04-01 07:25 : id 74 -> /nix/store/q676f4hvizjwxz55b73s1kwpimb9zybr-home-manager-generation
2021-04-01 07:13 : id 73 -> /nix/store/3bvifdmw7wq6l4axm9303hh536zpv5br-home-manager-generation
2021-03-29 03:48 : id 72 -> /nix/store/q676f4hvizjwxz55b73s1kwpimb9zybr-home-manager-generation
2021-03-26 17:20 : id 71 -> /nix/store/vja2mv341nr7pgijdapn2m2s23yzmsk8-home-manager-generation
```

You can either use the direct path from the command output, or compute it yourself using this 'formula': `/nix/var/nix/profiles/per-user/$(whoami)/home-manager-${ID}-link`.

```shell
$ nix-store -qR /nix/var/nix/profiles/per-user/msfjarvis/home-manager-74-link
/nix/store/fnkixi37wfz5nlyzwab2l51p29793a1m-libunistring-0.9.10
/nix/store/ai6j2i00rik53akq8r5pi2nqjvrqi7ky-libidn2-2.3.0
/nix/store/90illc73xfs933d06daq6d41njs8yh66-glibc-2.32-37
/nix/store/6hhqb94ilrdmh0cx5bhdqb92m6bqkvdj-zlib-1.2.11
/nix/store/3akvw7y0mfxq1l4xlpsqydm512ggn78p-libpng-apng-1.6.37
/nix/store/agprkg7bv4mnnhj7kddbhzhzm2w1iywj-libjpeg-turbo-2.0.6
/nix/store/r64zwzppipac695hx9vwgawmg1k0w20f-pcre-8.44
/nix/store/6cgq2g3v1jhr793qx6j6hr2mpicg0lp7-libselinux-3.0
/nix/store/bb4l2lmd6vrcyy40ciac8g6wb49a8szp-util-linux-2.36.1
/nix/store/j924jn8sw7kggc773wllw3kmimmr8z4x-libffi-3.3
/nix/store/cxbw3sfj8vvp2v7yydpd2f5xhsfn68zd-glib-2.66.4
/nix/store/2cw85jfh8yj20cj62lcs21y5jfcq28bi-xz-5.2.5
/nix/store/fmxgxr7kx29aqbzjp662v5mhkrbjvl91-gcc-10.2.0-lib
...
```

To diff, do this:

```shell
$ diff -Naur <(nix-store -qR /nix/var/nix/profiles/per-user/msfjarvis/home-manager-74-link | sort) <(nix-store -qR /nix/var/nix/profiles/per-user/msfjarvis/home-manager-73-link | sort)
```

Using `sort` on the result ensures that the diffs only contain actual changes and not just derivations changing their location in the `nix-store` output for any reason.
