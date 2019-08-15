(* things store cats behind attributes *)
type attribute = string
type t

(* json interface *)
val of_json : Yojson.Basic.t -> t option
val to_json : t -> Yojson.Basic.t

(* basic comparisons *)
val compare : t -> t -> int
val equal : t -> t -> bool
val hash : t -> int

(* for printing *)
val to_string : t -> string

(* getting attributes *)
val attributes : t -> attribute list
val attribute : t -> attribute -> Cat.t option