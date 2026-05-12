{ pkgs, ... }:
{
  imports = [
    ./packages.nix
  ];

  # === Nix 本体の設定 ===
  nix.settings = {
    # flake と nix コマンドの新インターフェースを有効化
    experimental-features = [ "nix-command" "flakes" ];

    # 重複ファイルをハードリンクで共有してストアサイズを削減
    auto-optimise-store = true;
  };

  # 古い世代を自動 GC（毎日 3:15 に 14日以上前を削除）
  nix.gc = {
    automatic = true;
    interval = { Hour = 3; Minute = 15; };
    options = "--delete-older-than 14d";
  };

  # === nix-darwin の互換バージョン ===
  # 新規セットアップなので最新を指定。途中で上げないこと（state migration の起点になる）
  system.stateVersion = 6;

  # === ターゲットアーキテクチャ ===
  # Apple Silicon のみを想定。Intel Mac に展開するなら x86_64-darwin に切り替え
  nixpkgs.hostPlatform = "aarch64-darwin";

  # === zsh のシステム連携 ===
  # nix-darwin が /etc/zshenv に Nix プロファイルへの PATH を追加する
  programs.zsh.enable = true;

  # === macOS のデフォルト設定（必要に応じて追加） ===
  system.defaults = {
    NSGlobalDomain = {
      # 拡張子を Finder に常に表示
      AppleShowAllExtensions = true;
      # キーリピート速度
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
    finder = {
      AppleShowAllFiles = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };
  };
}
