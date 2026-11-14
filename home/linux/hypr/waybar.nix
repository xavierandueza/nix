{ ... }:

{
  programs = {
    waybar = {
      enable = true;
      systemd.enable = true;

      settings = {
        mainbar = {
          layer = "top";
          position = "top";
          height = 27;
          output = [
            "*"
          ];
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [
            "bluetooth"
            "network"
            "wireplumber"
            "battery"
          ];

          clock = {
            tooltip = false;
          };

          bluetooth = {
            format = "{icon}";
            format-on = "";
            format-off = "󰂲";
            format-connected = "󰂱";
            tooltip-format = "{status} {device_alias}";
          };

          network = {
            format = "{icon}";
            format-icons = [
              "󰤯"
              "󰤟"
              "󰤢"
              "󰤥"
              "󰤨"
            ];
            format-disconnected = "󰤮";
            format-disabled = "󰤫";
            tooltip-format-wifi = "{essid} ({signalStrength}%)";
            tooltip-format-disconnected = "Disconnected";
          };

          wireplumber = {
            format = "{icon}";
            format-muted = "";
            format-icons = [
              ""
              ""
              ""
            ];
            tooltip-format = "{volume}% {node_name}";
          };

          battery = {
            format = "{icon}<span font_size='6pt'> </span>{capacity}%";
            format-icons = {
              default = [
                "󰂎"
                "󰁺"
                "󰁻"
                "󰁼"
                "󰁽"
                "󰁾"
                "󰁿"
                "󰂀"
                "󰂁"
                "󰂂"
                "󰁹"
              ];
              charging = [
                "󰢟"
                "󰢜"
                "󰂆"
                "󰂇"
                "󰂈"
                "󰢝"
                "󰂉"
                "󰢞"
                "󰂊"
                "󰂋"
                "󰂄"
              ];
            };
          };

          "hyprland/workspaces" = {
            update-active-window = true;
            persistent-workspaces."*" = [
              1
              2
              3
              4
              5
            ];
            format = "{icon}";
            format-icons = {
              active = "";
            };
          };
        };
      };
      style = ''
          * {
        	  border: none;
        	  border-radius: 0;
        	  font-size: 12px;
        	  font-family: "JetBrainsMono Nerd Font";
        	}

        	window#waybar {
        	  background: #1b1b2b;
        	  color: #c8d3f5;
        	}

        	#workspaces {
        	  margin-left: 8px;
        	}

          #bluetooth {
            margin-right: 10px;
          }
          
          #network {
            margin-right: 14px;
          }

          #wireplumber {
            margin-right: 14px;
          }

        	#battery {
        	  margin-right: 12px;
        	}

        	#workspaces button {
        	  padding: 0 6px;
        	  margin: 0;
        	  min-width: 0;
        	  color: #c8d3f5;
        	}

          #workspaces button.empty {
            color: alpha(#c8d3f5, 0.35);
          }

        	#workspaces button.active {
        	  color: #c8d3f5;
        	}
      '';
    };
  };
}
