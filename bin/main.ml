open Wyag.Init
open Cmdliner 

let main () = Cmd.eval init_cmd
let () = if !Sys.interactive then () else exit (main ())
