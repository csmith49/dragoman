type index = int
type relation = string
let wanted : relation -> bool = fun str ->
    CCList.mem ~eq:CCString.equal str [
        "left" ; "right" ; "front" ; "behind"
    ]

module RelMap = CCMap.Make(CCString)

type t = {
    things : Thing.t list;
    relations : (index * index) list RelMap.t;
}

(* utilities for parsing from json *)
let index_of_json : Yojson.Basic.t -> index option = function
    | `Int i -> Some i
    | _ -> None
let index_list_of_json : Yojson.Basic.t -> index list option = function
    | `List ls -> CCList.map index_of_json ls |> CCList.all_some
    | _ -> None
let rel_of_json : Yojson.Basic.t -> (index * index) list option = function
    | `List ls -> ls
        |> CCList.mapi (fun i -> fun v ->
            match index_list_of_json v with
                | Some js -> Some (js |> CCList.map (fun j -> (i, j)))
                | _ -> None
        )
        |> CCList.all_some
        |> CCOpt.map CCList.flatten
    | _ -> None

let of_json = function
    | `Assoc ls ->
        let things = match CCList.assoc_opt ~eq:CCString.equal "objects" ls with
            | Some (`List ls) -> ls
                |> CCList.map Thing.of_json
                |> CCList.all_some
            | _ -> None in
        let relations = match CCList.assoc_opt ~eq:CCString.equal "relations" ls with
            | Some (`Assoc ls) -> ls
                |> CCList.map (fun (k, v) ->
                    if wanted k then match rel_of_json v with
                        | Some rel -> Some (k, rel)
                        | _ -> None
                    else None)
                |> CCList.all_some
                |> CCOpt.map RelMap.of_list 
            | _ -> None in
        begin match things, relations with
            | Some things, Some relations -> Some {
                things = things ; relations = relations
            }
            | _ -> None end
    | _ -> None
let to_json _ = `Null

let to_string scene = Yojson.Basic.to_string (to_json scene)

let thing scene i = CCList.get_at_idx i scene.things

let relations scene = scene.relations
    |> RelMap.to_list
    |> CCList.map fst

let relation scene rel = RelMap.get rel scene.relations
