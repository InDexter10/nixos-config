{ pkgs, ... }:

let
  # --settings ile verilen dosya flagSettings katmanina duser: uygulama bu
  # katmani hicbir zaman yazmaz ve ~/.claude/settings.json onu gevsetemez.
  policy = pkgs.writeText "claude-code-policy.json" (
    builtins.toJSON {
      permissions = {
        # Calisma alani yalnizca cwd. Disari cikan her erisim izin dialogu acar.
        defaultMode = "default";
        additionalDirectories = [ ];

        deny = [
          "Read(~/.ssh/**)"
          "Edit(~/.ssh/**)"
          "Read(~/.gnupg/**)"
          "Edit(~/.gnupg/**)"
          "Read(~/.claude/.credentials.json)"
          "Edit(~/.claude/.credentials.json)"
          "Read(~/.local/share/keyrings/**)"
          "Read(~/.var/app/org.mozilla.firefox/**)"
          "Read(~/.netrc)"
          "Read(~/.git-credentials)"
          "Read(~/.aws/**)"
          "Read(~/.kube/**)"
          "mcp__claude_ai_Google_Drive"
          "mcp__claude_ai_Claude_Docs"
        ];

        # ask, allow'u ezer: alt katmanlardaki "bir daha sorma" bunlari acamaz.
        ask = [
          "WebFetch"
          "WebSearch"
        ];
      };

      # Transkriptler dosya iceriklerinin duz metin kopyasidir.
      cleanupPeriodDays = 7;
    }
  );

  # stable kanal claude-code'u dondurur (26.05 = 2.1.223); yeni modeller CLI
  # bundle'ina gomulu oldugu icin stable'da gorunmez. Unstable'dan cekilir.
  claude-code = pkgs.symlinkJoin {
    name = "claude-code-hardened";
    paths = [ pkgs.unstable.claude-code ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    # FORCE_AUTOUPDATE_PLUGINS upstream wrapper'da --set-default ile 1;
    # burada --set kullanildigi icin bu deger kazanir.
    #
    # CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC tek basina telemetriyi,
    # GrowthBook feature-flag cagrilarini ve diger zorunlu olmayan aglari
    # keser; DISABLE_TELEMETRY/DISABLE_ERROR_REPORTING ikinci savunma katmani.
    # --set-default: varsayilan kapali, tek seferlik teshis icin disardan
    # CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=0 ile ezilebilir.
    postBuild = ''
      wrapProgram $out/bin/claude \
        --add-flags "--settings ${policy}" \
        --set FORCE_AUTOUPDATE_PLUGINS 0 \
        --set DISABLE_TELEMETRY 1 \
        --set DISABLE_ERROR_REPORTING 1 \
        --set-default CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC 1 \
        --set DISABLE_BUG_COMMAND 1 \
        --set CLAUDE_CODE_DISABLE_OFFICIAL_MARKETPLACE_AUTOINSTALL 1
    '';
  };
in
{
  home.packages = [ claude-code ];
}
