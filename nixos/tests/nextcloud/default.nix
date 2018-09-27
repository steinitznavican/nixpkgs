{ system ? builtins.currentSystem }:
{
  basic = import ./basic.nix { inherit system; };
  with-postgresql-and-redis = import ./with-postgresql-and-redis.nix { inherit system; };
}
