{
  config,
  lib,
  pkgs,
}:
{
  strip_profile_imports =
    profile:
    let
      profile_attrs = import profile { inherit config lib pkgs; };
    in
    {
      config,
      lib,
      pkgs,
      ...
    }:
    (profile_attrs // { imports = [ ]; });
}
