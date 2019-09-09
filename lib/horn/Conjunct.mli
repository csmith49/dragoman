type t

(* getters *)
val variables : t -> Variable.t list

(* manipulation *)
val remap : t -> (Variable.t * Variable.t) list -> t

(* getting and setting from json *)
val of_json : Yojson.Basic.t -> t option
val to_json : t -> Yojson.Basic.t

(* printing *)
val to_string : t -> string

(* structural equality *)
val equal : t -> t -> bool
(* equality modulo renaming, extending first argument *)
val equal_wrt_mapping : Variable.Mapping.t -> t -> t -> Variable.Mapping.t option

(* making a simple table *)
val evaluate : t -> Core.Scene.t -> Table.t option