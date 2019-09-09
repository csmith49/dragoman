(* helper type to promote scene sharing *)
type index = (int * int)

(* the default, required types *)
type t = {
    scenes : Core.Scene.t list;
    positive : index list;
    negative : index list;
}

type input = Core.Scene.t
type output = Core.Thing.t
type example = input * output

(* utility function to help with pos and neg *)
let get spec index = let open CCOpt.Infix in
    let scene_index, obj_index = index in
    let scene = CCList.get_at_idx scene_index spec.scenes in
    let obj = scene >>= (fun s -> Core.Scene.thing s obj_index) in
    match scene, obj with
        | Some scene, Some obj -> Some (scene, obj)
        | _ -> None
        
(* the example generators - they fail silently *)
let positive spec = spec.positive |> CCList.filter_map (get spec)
let negative spec = spec.negative |> CCList.filter_map (get spec)