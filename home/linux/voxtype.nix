{ pkgs, ... }:

let
  # nixpkgs' ONNX build leaves out the Cohere Transcribe engine.
  voxtype = pkgs.voxtype-onnx.overrideAttrs (old: {
    cargoBuildFeatures = old.cargoBuildFeatures ++ [ "cohere" ];
    cargoCheckFeatures = old.cargoCheckFeatures ++ [ "cohere" ];
  });
in
{
  # Settings are left unset so `voxtype configure` owns ~/.config/voxtype/config.toml.
  services.voxtype = {
    enable = true;
    package = voxtype;
  };

  # Bound by keycode so Caps Lock (BackSpace keysym via colemak) stays a normal backspace.
  # wtype's virtual keyboard is excluded because it reuses keycode 22 for typed text.
  wayland.windowManager.hyprland.extraConfig = ''
    -- Push-to-talk on the physical Backspace key
    local not_wtype = { inclusive = false, list = { "hl-virtual-keyboard-wtype" } }
    hl.bind("code:22", hl.dsp.exec_cmd("voxtype record start"), { device = not_wtype });
    hl.bind("code:22", hl.dsp.exec_cmd("voxtype record stop"), { release = true, device = not_wtype });
  '';
}
