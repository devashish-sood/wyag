open File
open Inifiles

type repository = {
  work_tree : string;
  git_dir : string;
  conf : Inifiles.inifile;
}

type repo_error =
  | Already_exists of string
  | Not_found of string
  | Not_a_repo of string
  | Corrupted of string
  | Unsupported_version of string

let error_to_string = function
  | Already_exists path -> Printf.sprintf "repository already exists at %s" path
  | Not_found path -> Printf.sprintf "directory not found: %s" path
  | Not_a_repo path ->
      Printf.sprintf "not a git repository (or any parent): %s" path
  | Corrupted path ->
      Printf.sprintf "corrupted repository (config missing): %s" path
  | Unsupported_version v ->
      Printf.sprintf "unsupported repository format version: %s" v

let create_repository path =
  let git_dir = Filename.concat path ".git" in
  if Sys.file_exists git_dir then Error (Already_exists git_dir)
  else
    let config_path = Filename.concat git_dir "config" in
    ensure_dirs path [ ".git" ];
    create_file config_path "[core]\nrepositoryformatversion = 0\nbare = false";
    let config = new inifile config_path in
    Ok { work_tree = path; git_dir; conf = config }

let open_repository path =
  let git_dir = Filename.concat path ".git" in
  let config_path = Filename.concat git_dir "config" in
  if not (Sys.file_exists path && Sys.is_directory path) then
    Error (Not_found path)
  else if not (Sys.file_exists git_dir && Sys.is_directory git_dir) then
    Error (Not_a_repo path)
  else if not (Sys.file_exists config_path) then Error (Corrupted git_dir)
  else
    let config = new inifile config_path in
    let version = config#getval "core" "repositoryformatversion" in
    if version = "0" then Ok { work_tree = path; git_dir; conf = config }
    else Error (Unsupported_version version)
