open Utils

(** [build_path base path] concatenates a list of path components onto a base
    path. Example: [build_path "/home" ["user"; "docs"]] returns
    ["/home/user/docs"] *)
let build_path base path : string =
  List.fold_left (fun acc elem -> Filename.concat acc elem) base path

(** Alias for [build_path], used for constructing paths within a repository. *)
let repo_path = build_path

(** [ensure_dirs base path] creates directories for each component in [path],
    starting from [base]. Assumes [base] already exists and is a directory.
    @raise Failure if a path component exists but is not a directory. *)
let rec ensure_dirs base path =
  match path with
  | [] -> Ok ()
  | hd :: tl -> (
      let base = Filename.concat base hd in
      match Sys.file_exists base with
      | true -> (
          match Sys.is_directory base with
          | true -> ensure_dirs base tl
          | false -> Error (Not_a_dir base))
      | false ->
          Sys.mkdir base 0o755;
          ensure_dirs base tl)

let ensure_dir path = ensure_dirs "" path

(** [create_file path content] writes [content] to a file at [path], creating or
    overwriting the file. Returns [Ok ()] on success or [Error] on failure. *)
let create_file path content =
  try
    let oc = open_out path in
    output_string oc content;
    close_out oc;
    Ok ()
  with Sys_error msg -> Error (WriteError (path, msg))
