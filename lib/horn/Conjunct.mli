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
(* equality modulo renaming, extending first argument *)
val equal_wrt_mapping : Core.Variable.Mapping.t -> t -> t -> Core.Variable.Mapping.t option

(* making a simple table *)
val evaluate : t -> Core.Scene.t -> Core.Table.t option

(* generating sql statements that produce the same table as evaluate *)
val to_sql : t -> SQL.Query.t