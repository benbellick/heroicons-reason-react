(** To explain some terminology:
    - Size: One of 16, 20, or 24
    - Flavor: One of Outline, Solid, Mini, or Micro

    All icons in one size x flavor get put into one file at e.g.
    src/S16/outline.re *)

let make_icon_string folder icon =
  (* The name ends with Icon, so we drop that at the end *)
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

(** The root env variable is set within `.envrc` *)
let root = Sys.getenv "ROOT"

let hero_root = root ^ "/node_modules/@heroicons/react/"

(** [sizes] will contain 16, 20, 24 *)
let sizes =
  hero_root |> Sys.readdir |> Array.to_list
  |> List.filter (fun f -> Option.is_some (int_of_string_opt f))

let make_size_target_folder size =
  let target_dir = root ^ "/src/" ^ ("S" ^ size) ^ "/" in
  let () =
    if not (Sys.file_exists target_dir) then Sys.mkdir target_dir 0o777
  in
  target_dir

let render_size_to_module ~target_dir size =
  let dir = hero_root ^ size ^ "/" in
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
        List.map (make_icon_string (size ^ "/" ^ flavor)) icons
      in
      String.concat "\n" icon_modules
    in
    let target_file = target_dir ^ flavor ^ ".re" in
    let oc = open_out target_file in
    Printf.fprintf oc "%s\n" full_module;
    close_out oc
  in
  List.iter render_flavor_to_module flavors

let handle_size_folder size =
  let target_dir = make_size_target_folder size in
  render_size_to_module ~target_dir size

let () = List.iter handle_size_folder sizes
