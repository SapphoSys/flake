{ osConfig, pkgs, ... }:

{
  programs.vscode = {
    inherit (osConfig.settings.profiles.graphical) enable;
    package = pkgs.vscode-insiders;

    profiles.default.userSettings = {
      catppuccin.accentColor = "pink";

      chat.tools.terminal.outputLocation = "chat";

      diffEditor = {
        experimental.showMoves = true;
        ignoreTrimWhitespace = false;
        renderSideBySide = true;
      };

      editor = {
        accessibilitySupport = "off";
        bracketPairColorization.independentColorPoolPerBracketType = true;
        cursorBlinking = "smooth";
        cursorSmoothCaretAnimation = "on";
        fontFamily = "Iosevka, Iosevka Nerd Font, 'monospace', monospace";
        fontLigatures = true;
        fontSize = 13;
        formatOnPaste = true;
        minimap.enabled = false;
        smoothScrolling = true;
        stickyScroll.enabled = false;
        tabSize = 2;
        unicodeHighlight = {
          allowedLocales = {
            "ru" = true;
          };

          invisibleCharacters = false;
        };
      };

      emmet.preferences.output.inlineBreak = 1;

      explorer = {
        compactFolders = false;
        confirmDelete = false;
        confirmDragAndDrop = false;
      };

      files = {
        associations = {
          "*.css" = "tailwindcss";
          "*.mdx" = "markdown";
        };

        trimFinalNewlines = true;
      };

      git = {
        confirmSync = false;
        enableSmartCommit = true;
      };

      # Disable auto-fetch on macOS due to permission nags
      githubRepositories.autoFetch.enabled = if pkgs.stdenv.hostPlatform.isDarwin then false else true;

      javascript.updateImportsOnFileMove.enabled = "never";

      nix = {
        enableLanguageServer = true;
        serverPath = "nil";
        serverSettings = {
          nil.formatting.command = [ "nixfmt" ];
        };
      };

      terminal.integrated = {
        defaultProfile.windows = "PowerShell";
        fontFamily = "JetBrainsMono Nerd Font, Iosevka Nerd Font, Iosevka, MesloLGS NF, 'monospace', monospace";
      };

      typescript.updateImportsOnFileMove.enabled = "never";

      # window = {
      #   title = "\${dirty}\${activeEditorShort}\${separator}\${rootNameShort}\${separator}\${profileName}\${separator}\${appName}";
      #   titleBarStyle = "custom";
      # };

      workbench = {
        colorTheme = "Catppuccin Mocha";
        customTitleBarVisibility = "auto";
        editor.empty.hint = "hidden";
        iconTheme = "catppuccin-mocha";
        list.smoothScrolling = true;
        productIconTheme = "icons-carbon";
        startupEditor = "none";
      };

      vscord = {
        app.id = "1152314975466029187";

        status = {
          # details.text = {
          #   debugging = "👾 Debugging {workspace}";
          #   editing = "💾 Editing {file_name}{file_extension} | {line_count} lines | {file_size}";
          #   idle = "⏳ Idling";
          #   notInFile = "✨ Not in a file!";
          #   viewing = "🔍 Viewing {file_name}{file_extension}";
          # };

          image = {
            large = {
              debugging = {
                # text = "Debugging a {lang} file";
                key = "https://vscord.catppuccin.com/mocha/debugging.webp";
              };

              editing = {
                # text = "Editing a {lang} file";
                key = "https://vscord.catppuccin.com/mocha/{lang}.webp";
              };

              idle = {
                key = "https://vscord.catppuccin.com/mocha/idle-{app_id}.webp";
              };

              notInFile = {
                key = "https://vscord.catppuccin.com/mocha/idle-{app_id}.webp";
              };

              viewing = {
                # text = "Viewing a {lang} file";
                key = "https://vscord.catppuccin.com/mocha/{lang}.webp";
              };
            };

            small = {
              debugging = {
                key = "https://vscord.catppuccin.com/mocha/debugging.webp";
              };
              editing = {
                key = "https://vscord.catppuccin.com/mocha/{app_id}.webp";
              };
              idle = {
                key = "https://vscord.catppuccin.com/mocha/idle.webp";
              };
              notInFile = {
                # text = "eepy";
                key = "https://vscord.catppuccin.com/mocha/idle.webp";
              };
              viewing = {
                key = "https://vscord.catppuccin.com/mocha/{app_id}.webp";
              };
            };
          };

          # state.text = {
          #   debugging = "🪄 Debugging {workspace}";
          #   editing = "📝 Working on {workspace_folder}";
          #   idle = "🕑 Will be back soon... (hopefully)";
          #   notInFile = "🔎 Choosing what to work on...";
          #   viewing = "📂 Working on {workspace_folder}";
          # };
        };
      };
    };
  };
}
