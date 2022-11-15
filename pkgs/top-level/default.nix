{ config ? (builtins.trace "Default config is used" {}), ... }@args:
import ./overlay.nix (import ../../lib/channels) args
