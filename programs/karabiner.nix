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
        devices = [
          {
            identifiers = {
              device_address = "ef-77-f5-a8-0f-4f";
              is_keyboard = true;
              is_pointing_device = true;
            };
            ignore = false;
          }
          {
            identifiers = {
              vendor_id = 12815;
              product_id = 20565;
              is_keyboard = true;
            };
            ignore = false;
          }
        ];
        virtual_hid_keyboard.keyboard_type_v2 = "ansi";
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
          {
            description = "Backspace -> option + space for Handy recording";
            manipulators = [
              {
                type = "basic";
                from.key_code = "delete_or_backspace";
                to = [
                  {
                    key_code = "spacebar";
                    modifiers = [ "left_option" ];
                  }
                ];
              }
            ];
          }
        ];
      }
    ];
  };
  };
}
