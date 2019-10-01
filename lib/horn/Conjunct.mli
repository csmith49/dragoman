type t

(* getters *)
val variables : t -> Core.Variable.t list

(* manipulation *)
val remap : t -> (Core.Variable.t * Core.Variable.t) list -> t

(* getting and setting from json *)
val of_json : Yojson.Basic.t -> t option
val to_json : t -> Yojson.Basic.t

(* printing *)
val to_string : t -> string

(* structural equality *)
val equal : t -> t -> bool

val to_query : t -> Core.Query.t