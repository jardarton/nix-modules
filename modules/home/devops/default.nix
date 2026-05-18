{ localFlake, ... }:
{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.home.devops;
in
{

  options.modules.home.devops = {
    enableDocker = mkEnableOption "enable docker and related";
    enableK8sTools = mkEnableOption "enable k8s tools";
    enableLima = mkEnableOption "enable lima for macos";
  };
  config = {

    home.packages =
      with pkgs;
      [ ]
      ++ (
        if cfg.enableDocker then
          [
            docker
            podman
          ]
        else
          [ ]
      )
      ++ (
        if cfg.enableK8sTools then
          [
            k3sup
            kubectl
            kind
            kubernetes-helm
            fluxcd
            kustomize
            cilium-cli
            kubefetch
            kubeseal
            helmfile
            talosctl
            talhelper
            cmctl
          ]
        else
          [ ]
      )
      ++ (
        if cfg.enableLima then
          [
            lima-additional-guestagents
            lima
            colima
          ]
        else
          [ ]
      );

    programs.lazydocker = {
      enable = cfg.enableDocker;
    };

    services.colima = {

      enable = true;
    };

    programs.k9s = {
      enable = cfg.enableK8sTools;
      settings = {
        skin = "skin";
      };
    };

    programs.kubecolor = {
      enable = cfg.enableK8sTools;
      enableZshIntegration = true;
    };

    programs.zsh.initContent =
      ""
      + (
        if cfg.enableK8sTools then
          ''
            source <(kubectl completion zsh)
            source <(flux completion zsh)
            source <(kustomize completion zsh)

          ''
        else
          ""
      )
      + (
        if cfg.enableLima then
          ''
            source <(limactl completion zsh)
            source <(colima completion zsh)
          ''
        else
          ""
      );

    home.shellAliases = {
      k = mkIf cfg.enableK8sTools "kubectl";
      limakube = mkIf cfg.enableLima ''export KUBECONFIG="${config.home.homeDirectory}/.lima/k8s/copied-from-guest/kubeconfig.yaml"'';
      limassh = mkIf cfg.enableLima "ssh -F ~/.lima/default/ssh.config lima-default";
      ld = mkIf cfg.enableDocker "lazydocker";
    };
  };

}
