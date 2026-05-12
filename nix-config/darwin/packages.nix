{ pkgs, ... }:
{
  # 旧 Brewfile の brew (CLI) 群 + leaves から移植。GUI (cask) は Homebrew 側で継続管理。
  # ※ ここに無いものは brew で個別に入れているか、依存として自動で入ったもの。
  environment.systemPackages = with pkgs; [
    # === Git / GitHub / dotfiles ===
    git
    gh
    git-secrets
    chezmoi

    # === Shell / prompt / navigation ===
    starship
    fzf
    peco
    fd
    ripgrep
    jq
    zoxide
    yazi

    # === Runtime version manager / direnv ===
    mise
    direnv

    # === Build essentials（PHP 等のソースビルド向け） ===
    autoconf
    automake
    bison
    pkg-config
    re2c

    # === Cloud / container ===
    awscli2
    docker-compose
    kubectl
    kubernetes-helm
    k9s
    k6

    # === Network / file ===
    aria2
    p7zip
    poppler

    # === CI / workflow tools ===
    act
    actionlint

    # === Languages / runtimes ===
    php
    nodejs
    jdk

    # === Media（重い。不要なら削減） ===
    imagemagick
    ffmpeg

    # === Misc ===
    mkcert
    redis
    cocoapods
  ];
}
