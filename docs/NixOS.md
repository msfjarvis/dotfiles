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
patchelf --set-interpreter "$(nix eval --raw nixpkgs.glibc.outPath)/lib/ld-linux-x86-64.so.2" $(command -v adb)
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

Install [nvd](https://gitlab.com/khumba/nvd)

```shell
$ nix-env -iA nixpkgs.nvd
```

Get the store paths and call `nvd diff`

```shell
$ home-manager generations
2021-10-15 18:22 : id 135 -> /nix/store/66vgjgg2rfpjhcs065gc5fn8pkiq10wd-home-manager-generation
2021-10-10 19:45 : id 134 -> /nix/store/j4g7wmd7yfd47zr5pc86p9aaalmi05qc-home-manager-generation
2021-10-10 12:16 : id 133 -> /nix/store/kh1c4g37kda90a1zzsynrbjcfw79sz3s-home-manager-generation

$ nvd diff /nix/store/j4g7wmd7yfd47zr5pc86p9aaalmi05qc-home-manager-generation /nix/store/66vgjgg2rfpjhcs065gc5fn8pkiq10wd-home-manager-generation<<< /nix/store/j4g7wmd7yfd47zr5pc86p9aaalmi05qc-home-manager-generation
>>> /nix/store/66vgjgg2rfpjhcs065gc5fn8pkiq10wd-home-manager-generation
Version changes:
[U.]  #1  cargo-nightly-complete                 2021-10-10 -> 2021-10-13
[U.]  #2  clippy-preview-nightly-complete        2021-10-10 -> 2021-10-13
[U.]  #3  rust-nightly-complete-with-components  2021-10-10 -> 2021-10-13
[U.]  #4  rust-src-nightly-complete              2021-10-10 -> 2021-10-13
[U.]  #5  rust-std-nightly-complete              2021-10-10 -> 2021-10-13
[U.]  #6  rustc-nightly-complete                 2021-10-10 -> 2021-10-13
[U.]  #7  rustfmt-preview-nightly-complete       2021-10-10 -> 2021-10-13
Added packages:
[A.]  #1  rust-analyzer-nightly           137ac67
[A.]  #2  vscode-extension-rust-analyzer  137ac67
Removed packages:
[R.]  #1  rust-analyzer-nightly-ce86534           <none>
[R.]  #2  vscode-extension-rust-analyzer-ce86534  <none>
Closure size: 535 -> 535 (13 paths added, 13 paths removed, delta +0).
```
