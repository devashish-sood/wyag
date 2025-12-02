type repo_error =
  | Already_exists of string
  | Not_found of string
  | Not_a_repo of string
  | Not_a_dir of string
  | Corrupted of string
  | WriteError of string * string
  | Unsupported_version of string

let error_to_string = function
  | Already_exists path -> Printf.sprintf "repository already exists at %s" path
  | Not_found path -> Printf.sprintf "directory not found: %s" path
  | Not_a_repo path ->
      Printf.sprintf "not a git repository (or any parent): %s" path
  | Not_a_dir path -> Printf.sprintf "not a directory: %s" path
  | Corrupted path ->
      Printf.sprintf "corrupted repository (config missing): %s" path
  | WriteError (file, e) ->
      Printf.sprintf "Failed to write to file '%s': %s" file e
  | Unsupported_version v ->
      Printf.sprintf "unsupported repository format version: %s" v

let ( let* ) = Result.bind
let guard condition error = if condition then Ok () else Error error
