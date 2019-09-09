type t

(* getters *)
val variables : t -> Variable.t list
val conjuncts : t -> Conjunct.t list

(* manipulation *)
val remap : t -> (Variable.t * Variable.t) list -> t

(* getting and setting from json *)
val of_json : Yojson.Basic.t -> t option
val to_json : t -> Yojson.Basic.t

(* printing *)
val to_string : t -> string

(* the meat and potatos - evaluating to produce a table *)
val evaluate : ?verbose:bool -> t -> Core.Scene.t -> Table.t option