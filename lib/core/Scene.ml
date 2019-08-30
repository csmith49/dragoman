type index = int
type relation = string

module RelMap = CCMap.Make(CCString)

type t = {
    things : Thing.t list;
    relations : Relation.t RelMap.t;
}

let of_json json = let module J = Utility.JSON in let open CCOpt.Infix in
    let things = J.assoc json "objects" 
        >>= J.Parse.list Thing.of_json in
    let relations = J.assoc json "relationships"
        >>= J.Parse.assoc_some_items Relation.of_json |> CCOpt.map RelMap.of_list in
    match things, relations with
        | Some things, Some relations -> Some {
            things = things ; relations = relations
        }
        | _ -> None

(* TODO - implement *)
let to_json _ = `Null

let to_string scene = Yojson.Basic.to_string (to_json scene)

let thing scene i = CCList.get_at_idx i scene.things

let relations scene = scene.relations
    |> RelMap.to_list
    |> CCList.map fst

let relation scene rel = RelMap.get rel scene.relations

let things scene = scene.things
let things_idx scene = 
    CCList.mapi (fun i -> fun v -> (i, v)) scene.things