type t

(* construction and parsin *)
val to_string : t -> string
val to_int : t -> int
val of_int : int -> t

(* json stuff *)
val to_json : t -> Yojson.Basic.t
val of_json : Yojson.Basic.t -> t option

(* for container uses *)
val compare : t -> t -> int
val equal : t -> t -> bool
val hash : t -> int