type t

(* getters *)
val variables : t -> Core.Variable.t list
val conjuncts : t -> Conjunct.t list

(* manipulation *)
val remap : t -> (Core.Variable.t * Core.Variable.t) list -> t

(* getting and setting from json *)
val of_json : Yojson.Basic.t -> t option
val to_json : t -> Yojson.Basic.t

(* printing *)
val to_string : t -> string

(* conversions *)
val to_query : t -> Core.Query.t