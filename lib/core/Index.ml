type t = int

let to_string = CCInt.to_string
let to_int i = i
let of_int i = i

let to_json i = `Int i
let of_json = function
    | `Int i -> Some i
    | _ -> None

let compare = CCInt.compare
let equal = CCInt.equal
let hash = CCInt.hash