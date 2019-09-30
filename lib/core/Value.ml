type t = [
    | `Int of int
    | `Bool of bool
    | `String of string
]

(* json *)
let to_json = function
    | `Int i -> `Int i
    | `Bool b -> `Bool b
    | `String s -> `String s
let of_json = function
    | `Int i -> Some (`Int i)
    | `Bool b -> Some (`Bool b)
    | `String s -> Some (`String s)
    | _ -> None

(* for printing *)
let to_string = function
    | `Int i -> string_of_int i
    | `Bool b -> string_of_bool b
    | `String s -> s

(* conversion from string *)
let of_string str = match CCInt.of_string str with
    | Some i -> `Int i
    | None -> match bool_of_string_opt str with
        | Some b -> `Bool b
        | None -> `String str

(* to literals *)
let to_bool_literal = function
    | `Bool b -> Some b
    | _ -> None
let to_int_literal = function
    | `Int i -> Some i
    | _ -> None
let to_string_literal = function
    | `String s -> Some s
    | _ -> None

(* container stuff *)
let compare = Pervasives.compare
let equal l r = (compare l r) == 0
let hash = CCHash.poly