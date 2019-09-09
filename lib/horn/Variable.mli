type t

(* to and from json *)
val of_json : Yojson.Basic.t -> t option
val to_json : t -> Yojson.Basic.t

(* easy way of producing canonical forms *)
val of_indexed_rep : string -> int -> t

(* manipulation *)
type variable = t
module Mapping : sig
    type t = (variable * variable) list
    val remap : variable -> t -> variable
    val empty : t
    val make_equal_in : variable -> variable -> t -> t
end

(* basic comparisons so we can use in containers *)
val compare : t -> t -> int
val equal : t -> t -> bool
val hash : t -> int

(* for printing *)
val to_string : t -> string