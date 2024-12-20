let make_icon_string folder icon =
  let drop_last_four s =
    let len = String.length s in
    String.sub s 0 (len - 4)
  in
  let icon_mod_name = drop_last_four icon in
  Format.sprintf
    {|module %s = {
  [@mel.module "@heroicons/react/%s"] [@react.component]
  external make: (~className: string=?, ~ariaHidden: bool=?) => React.element =
    "%s";
 };|}
    icon_mod_name folder icon

let root = Sys.getenv "ROOT"
let hero_root = root ^ "/node_modules/@heroicons/react/"

let icon_folders =
  hero_root |> Sys.readdir |> Array.to_list
  |> List.filter (fun f -> Option.is_some (int_of_string_opt f))

let size_folder_to_dune folder =
  let dune_content =
    Format.sprintf
      {|(library
 (name %s)
 (preprocess
  (pps melange.ppx reason-react-ppx))
 (libraries reason-react)
 (modes melange))|}
      ("s" ^ folder)
  in
  let target_dir = root ^ "/src/" ^ ("S" ^ folder) ^ "/" in
  let () =
    if not (Sys.file_exists target_dir) then Sys.mkdir target_dir 0o777
  in
  let target_file = target_dir ^ "dune" in
  let oc = open_out target_file in
  Printf.fprintf oc "%s\n" dune_content;
  close_out oc

(** This refers to 20, 16 *)
let size_folder_to_module folder =
  let () = size_folder_to_dune folder in
  let dir = hero_root ^ folder ^ "/" in
  let flavors = Array.to_list @@ Sys.readdir dir in
  (* This refers to outline, solid, etc.  *)
  let render_flavor_to_module flavor =
    let icons =
      let dir = dir ^ flavor ^ "/" in
      let icon_file_to_icon_name icon_file =
        List.hd (String.split_on_char '.' icon_file)
      in
      dir |> Sys.readdir |> Array.to_list
      |> List.filter (String.ends_with ~suffix:"Icon.js")
      |> List.map icon_file_to_icon_name
    in
    let full_module =
      let icon_modules =
        List.map (make_icon_string (folder ^ "/" ^ flavor)) icons
      in
      String.concat "\n" icon_modules
    in

    let target_dir = root ^ "/src/" ^ ("S" ^ folder) ^ "/" in
    let () =
      if not (Sys.file_exists target_dir) then Sys.mkdir target_dir 0o777
    in
    let target_file = target_dir ^ flavor ^ ".re" in
    let oc = open_out target_file in
    Printf.fprintf oc "%s\n" full_module;
    close_out oc
  in
  List.iter render_flavor_to_module flavors

let () = List.iter size_folder_to_module icon_folders
