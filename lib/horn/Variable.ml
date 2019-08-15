type t = string

let of_json = function
    | `String s -> Some s
    | _ -> None
let to_json var = `String var

let compare = CCString.compare
let equal = CCString.equal
let hash = CCString.hash

let to_string var = var