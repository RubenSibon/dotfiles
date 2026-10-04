{
  description = "NixOS configuration: shared modules, plus one untracked directory per machine";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs = { nixpkgs, ... }: {
    # One configuration per directory in ./hosts, named after the machine's host name.
    # The repository does not track ./hosts: it holds host names, user names and disk IDs.
    nixosConfigurations = builtins.mapAttrs
      (host: _: nixpkgs.lib.nixosSystem { modules = [ ./hosts/${host} ]; })
      (if builtins.pathExists ./hosts then builtins.readDir ./hosts else { });
  };
}
