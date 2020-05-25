# Notes on NixOS usage for a future me, and probably other people.

Using NixOS is not straightforward, or simple. It's an ordeal to say the least, and a massive pain in the ass if we're being frank. But it's premise is very interesting, so we shall put up with this atrocity for the sake of science and sanity. Here's some things that were non-obvious and have been accordingly been resolved by me, documented for posterity.

## Running executables from the interwebs

The first thing you'll find is that simply downloading and running a 'static' executable will not work at all. You will receive errors of this sort:

```
/home/msfjarvis/Android/Sdk/platform-tools/adb: No such file or directory
```

`A N N O Y I N G`. Also fixable, sort of. The root of this problem is that most distros have their dynamic linker at `/lib/ld-linux-x86-64.so.2`, and traditional static builds will use that as the interpreter. Makes sense so far!

NixOS does not conform to this, and instead hosts it within the `glibc` package's `lib` directory. Now, the problem arises: how do I tell my binary that's where the linker it needs is? Turns out, NixOS solved that as well! They created a tool called `patchelf` that can perform multiple transformations on ELF binaries including setting their interpreter -- perfect for what we need.

This is a bit of a hack, but that's how I did it.

```
patchelf --set-interpreter "$(nix eval nixpkgs.glibc.outPath | sed 's/"//g')/lib/ld-linux-x86-64.so.2" ~/Android/Sdk/platform-tools/adb
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

this is not very documented and thus updating a package can be a pain. `nix-prefetch-url` to the rescue!

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
