import ../../pkgs/top-level/release.nix { # Don't apply ‘hydraJob’ to jobs, because then we can't get to the
  # dependency graph.
  scrubJobs = false;
  # No need to evaluate on i686.
  supportedSystems = [ "x86_64-linux" ];
  limitedSupportedSystems = [];
}
