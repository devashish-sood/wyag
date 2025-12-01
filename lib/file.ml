let build_path base path : string =
  List.fold_left (fun acc elem -> Filename.concat acc elem) base path

let repo_path = build_path

let rec ensure_dirs base path : unit =
  match path with
  | [] -> ()
  | hd :: tl -> (
      match Sys.file_exists base with
      | true -> (
          match Sys.is_directory base with
          | true -> ensure_dirs (Filename.concat base hd) tl
          | false -> failwith (base ^ " exists but is not a directory"))
      | false ->
          Sys.mkdir base 0o755;
          ensure_dirs (Filename.concat base hd) tl)

let create_file path content =
  let oc = open_out path in
  output_string oc content;
  close_out oc
