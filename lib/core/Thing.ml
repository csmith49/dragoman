type attribute = string

module AttrMap = CCMap.Make(CCString)

type t = Cat.t AttrMap.t

let of_json json = let module J = Utility.JSON in
    J.Parse.assoc_some_items Cat.of_json json |> CCOpt.map (AttrMap.of_list)

let to_json thing = `Assoc (thing
    |> AttrMap.map (Cat.to_json)
    |> AttrMap.to_list)

let compare = AttrMap.compare (Cat.compare)
let equal = AttrMap.equal (Cat.equal)
let hash = CCHash.poly

let to_string _ = "THING"

let attributes thing = thing
    |> AttrMap.to_list
    |> CCList.map fst
let attribute thing attr = AttrMap.find_opt attr thing