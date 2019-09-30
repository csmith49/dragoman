type relation_key = string

module RelMap = CCMap.Make(CCString)
module ValueMap = CCMap.Make(Value)

type t = {
    things : Thing.t ValueMap.t;
    relations : Relation.t RelMap.t;
}

(* CONSTRUCTION *)
let empty = {
    things = ValueMap.empty;
    relations = RelMap.empty;
}

let add_thing scene idx thing = {
    scene with things = ValueMap.add idx thing scene.things
}

let add_relation scene key relation = {
    scene with relations = RelMap.add key relation scene.relations
}

let of_json json = let module J = Utility.JSON in
    let things = J.Parse.get 
        "objects"
        (J.Parse.list Thing.of_json)
        json in
    let relations = J.Parse.get 
        "relationships"
        (fun j -> j |> J.Parse.assoc_some_items Relation.of_json |> CCOpt.map RelMap.of_list) 
        json in
    match things, relations with
        | Some things, Some relations -> 
            let things = things
                |> CCList.mapi (fun i -> fun thing -> (`Int i, thing))
                |> ValueMap.of_list in
            Some { things = things ; relations = relations }
        | _ -> None

(* TODO - implement *)
let to_json _ = `Null

let to_string scene = Yojson.Basic.to_string (to_json scene)

let thing scene i = ValueMap.get i scene.things

let relations scene = scene.relations
    |> RelMap.to_list
    |> CCList.map fst

let relation scene rel = RelMap.get rel scene.relations

let things_idx scene = ValueMap.to_list scene.things

let add_attribute_to_thing scene idx attr v =
    let thing = match thing scene idx with
        | Some thing -> thing
        | None -> Thing.empty in
    let thing' = Thing.add_attribute thing attr v in
    add_thing scene idx thing'
