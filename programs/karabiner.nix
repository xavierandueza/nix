_: {
  # Karabiner-Elements reads ~/.config/karabiner/karabiner.json. This file is
  # fully Nix-owned (read-only symlink), so edits made in the Karabiner GUI
  # will NOT persist — manage every rule here instead.
  home.file.".config/karabiner/karabiner.json" = {
    force = true;
    text = builtins.toJSON {
    global.show_in_menu_bar = false;
    profiles = [
      {
        name = "Default";
        selected = true;
        complex_modifications.rules = [
          {
            description = "Swap fn and left_control (built-in keyboard only)";
            manipulators = [
              {
                type = "basic";
                from.key_code = "fn";
                to = [ { key_code = "left_control"; } ];
                conditions = [
                  {
                    type = "device_if";
                    identifiers = [ { is_built_in_keyboard = true; } ];
                  }
                ];
              }
              {
                type = "basic";
                from.key_code = "left_control";
                to = [ { key_code = "fn"; } ];
                conditions = [
                  {
                    type = "device_if";
                    identifiers = [ { is_built_in_keyboard = true; } ];
                  }
                ];
              }
            ];
          }
          {
            description = "left_control + [ -> escape (all keyboards)";
            manipulators = [
              {
                type = "basic";
                from = {
                  key_code = "open_bracket";
                  modifiers.mandatory = [ "left_control" ];
                };
                to = [ { key_code = "escape"; } ];
              }
            ];
          }
        ];
      }
    ];
  };
  };
}
