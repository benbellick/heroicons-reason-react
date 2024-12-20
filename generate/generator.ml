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

let render_size_to_module size =
  let dir = hero_root ^ size ^ "/" in
  let flavors = Array.to_list @@ Sys.readdir dir in
  (* This refers to outline, solid, etc.  *)
  let flavor_to_module flavor =
    Format.printf "Creating module %s/%s...\n" size flavor;
    let icons =
      let dir = dir ^ flavor ^ "/" in
      let icon_file_to_icon_name icon_file =
        List.hd (String.split_on_char '.' icon_file)
      in
      dir |> Sys.readdir |> Array.to_list
      |> List.filter (String.ends_with ~suffix:"Icon.js")
      |> List.map icon_file_to_icon_name
    in
    let icon_modules =
      List.map (make_icon_string (size ^ "/" ^ flavor)) icons
    in
    let full_module = String.concat "\n" icon_modules in
    Format.sprintf
      {|module %s = {
                      %s
         }|}
      (String.capitalize_ascii flavor)
      full_module
  in
  let submodules = List.map flavor_to_module flavors in
  let size_module = String.concat "\n" submodules in

  let target_file = root ^ "/src/s" ^ size ^ ".re" in
  let oc = open_out target_file in
  Printf.fprintf oc "%s\n" size_module;
  close_out oc

let () =
  Format.printf "Generating wrapper code...\n\n";
  List.iter render_size_to_module sizes
