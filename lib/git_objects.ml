type tree_entry =
  | File of { name : string; mode : string; sha : string }
  | Dir of { name : string; sha : string }
(* | Symlink of { name: string; sha: string } *)

module StringMap = Map.Make (String)

type tree = tree_entry StringMap.t

type git_object =
  | Blob of string
  | Tree of tree
  | Commit of { tree : string; parents : string list; message : string }
