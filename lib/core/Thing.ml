type attribute = string

module AttrMap = CCMap.Make(CCString)

type t = Value.t AttrMap.t

let of_json json = let module J = Utility.JSON in
    J.Parse.assoc_some_items Value.of_json json |> CCOpt.map (AttrMap.of_list)

let to_json thing = `Assoc (thing
    |> AttrMap.map (Value.to_json)
    |> AttrMap.to_list)

let compare = AttrMap.compare (Value.compare)
let equal = AttrMap.equal (Value.equal)
let hash = CCHash.poly

let to_string _ = "THING"

let attributes thing = thing
    |> AttrMap.to_list
    |> CCList.map fst
let attribute thing attr = AttrMap.find_opt attr thing

(* construction *)
let empty = AttrMap.empty
let add_attribute thing attr cat = AttrMap.add attr cat thing
let add_attributes thing attrs = AttrMap.add_list thing attrs
