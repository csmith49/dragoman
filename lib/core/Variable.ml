type t = string

let of_json = Utility.JSON.Literal.string
let to_json var = `String var

let of_indexed_rep base index = base ^ "." ^ (string_of_int index)

let compare = CCString.compare
let equal = CCString.equal
let hash = CCString.hash

let to_string var = var

(* the mapping module *)
type variable = t
module Mapping = struct
    type t = (variable * variable) list

    (* triangle sub *)
    let rec remap var mapping = 
        let res = CCList.assoc_opt ~eq:equal var mapping |> CCOpt.get_or ~default:var in
        if equal var res then res else remap res mapping
    (* base constructor *)
    let empty = []
    (* add constraints easily *)
    let make_equal_in x y mapping =
        let x' = remap x mapping in
        let y' = remap y mapping in
        if equal x' y' then mapping else (x', y') :: mapping
end