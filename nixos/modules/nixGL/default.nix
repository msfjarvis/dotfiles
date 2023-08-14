{pkgs, ...}: binary: drv:
pkgs.symlinkJoin {
  name = "${drv.name}-nixglwrapped";
  paths = [drv];
  nativeBuildInputs = [pkgs.makeWrapper];
  postBuild = ''
    # This will break if wrapProgram is ever changed, so fingers crossed
    makeShellWrapper() {
      local original="$1"
      local wrapper="$2"
      cat << EOF > "$wrapper"
    #! ${pkgs.bash}/bin/bash -e
    exec "${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL" "$original"
    EOF
      chmod +x "$wrapper"
    }

    wrapProgram "$out/bin/${binary}"
  '';
}
