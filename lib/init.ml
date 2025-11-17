open Cmdliner
open Cmdliner.Term.Syntax

let init path = Printf.printf "Initializing repository at %s\n" path

let path =
  let doc = "path at which repository is to be initialized" in
  Arg.(value & pos 0 string "." & info [] ~doc ~docv:"path")

let init_cmd =
  let doc = "initialize a git repository" in
  Cmd.make (Cmd.info "init" ~doc)
  @@
  let+ path = path in
  init path
