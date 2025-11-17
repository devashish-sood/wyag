open Cmdliner
open Command.Init

let wyag_cmd = Cmd.group (Cmd.info "wyag") [ init_cmd ]
let main () = Cmd.eval wyag_cmd
let () = if !Sys.interactive then () else exit (main ())
