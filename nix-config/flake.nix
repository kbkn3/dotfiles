{
  description = "kbkn3 dotfiles - nix-darwin configuration";

  inputs = {
    # nixpkgs 本体（unstable は新しめパッケージが揃う。stable に切り替えるなら nixos-25.05 等）
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # macOS のシステム設定を Nix で宣言するためのモジュール群
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin }: {
    # 新しい PC で `darwin-rebuild switch --flake .#default` を実行する想定。
    # hostname 別に分けたいときは "default" を hostname に変えてエントリを追加する。
    darwinConfigurations."default" = nix-darwin.lib.darwinSystem {
      modules = [
        ./darwin/default.nix
      ];
    };
  };
}
