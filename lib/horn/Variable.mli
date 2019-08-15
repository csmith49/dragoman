type t

val of_json : Yojson.Basic.t -> t option
val to_json : t -> Yojson.Basic.t

val compare : t -> t -> int
val equal : t -> t -> bool
val hash : t -> int

val to_string : t -> string