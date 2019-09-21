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

(* the meat and potatos - evaluating to produce a table *)
val evaluate : ?verbose:bool -> t -> Core.Scene.t -> Core.Table.t option

(* and the sql version of the above *)
val to_sql : t -> SQL.Query.t