(* values are the things stored in tables, and can represent integers, strings, or booleans *)
type t = [
    | `Int of int
    | `Bool of bool
    | `String of string
]

(* converstion to and from json *)
val to_json : t -> Yojson.Basic.t
val of_json : Yojson.Basic.t -> t option

(* for printing *)
val to_string : t -> string

(* conversion from raw string *)
val of_string : string -> t

(* conversion to literals *)
val to_bool_literal : t -> bool option
val to_int_literal : t -> int option
val to_string_literal : t -> string option

(* for container stuff *)
val compare : t -> t -> int
val equal : t -> t -> bool
val hash : t -> int