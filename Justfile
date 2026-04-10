#!/usr/bin/env just --justfile

default:
    @just --list

jq:
    cd jq && nix build ".#default.out"
    cd jq && cat result/compile_commands.json

clean:
    cd jq && rm -f result

todo:
    rg "BUG"
