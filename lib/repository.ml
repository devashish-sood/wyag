open File
open Inifiles
open Utils

type repository = {
  work_tree : string;
  git_dir : string;
  conf : Inifiles.inifile;
}

let create_default_config git_dir =
  let config_path = Filename.concat git_dir "config" in
  let* () =
    create_file config_path
      "[core]\nrepositoryformatversion = 0\nfilemode = false\nbare = false"
  in
  Ok config_path

let create_head git_dir =
  let head_path = Filename.concat git_dir "HEAD" in
  create_file head_path "ref: refs/heads/master\n"

let create_description git_dir =
  let desc_path = Filename.concat git_dir "description" in
  create_file desc_path
    "Unnamed repository; edit this file to name the repository.\n"

let create_default_dirs git_dir =
  let* () = ensure_dirs git_dir [ "branches" ] in
  let* () = ensure_dirs git_dir [ "objects" ] in
  let* () = ensure_dirs git_dir [ "refs"; "tags" ] in
  let* () = ensure_dirs git_dir [ "refs"; "heads" ] in
  Ok ()

let create_repository path =
  let* () =
    guard
      ((not (Sys.file_exists path)) || Sys.is_directory path)
      (Not_a_dir path)
  in
  let git_dir = Filename.concat path ".git" in
  let* () =
    guard
      ((not (Sys.file_exists git_dir)) || Array.length (Sys.readdir git_dir) = 0)
      (Already_exists git_dir)
  in
  let* () = ensure_dirs path [ ".git" ] in
  let* () = create_default_dirs git_dir in
  let* config_path = create_default_config git_dir in
  let* () = create_head git_dir in
  let* () = create_description git_dir in
  let config = new inifile config_path in
  Ok { work_tree = path; git_dir; conf = config }

let open_repository path =
  let git_dir = Filename.concat path ".git" in
  let config_path = Filename.concat git_dir "config" in
  let* () =
    guard (Sys.file_exists path && Sys.is_directory path) (Not_found path)
  in
  let* () =
    guard
      (Sys.file_exists git_dir && Sys.is_directory git_dir)
      (Not_a_repo path)
  in
  let* () = guard (Sys.file_exists config_path) (Corrupted git_dir) in
  let config = new inifile config_path in
  let version = config#getval "core" "repositoryformatversion" in
  if version = "0" then Ok { work_tree = path; git_dir; conf = config }
  else Error (Unsupported_version version)
