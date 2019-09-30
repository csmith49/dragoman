type relation_key = string

type selector = [
    | `Equality of Variable.t * Value.t
    | `And of selector * selector
    | `Or of selector * selector
]

type t = [
    | `Relation of relation_key
    | `Select of selector * t
    | `Project of Variable.t list * t
    | `Rename of Variable.Mapping.t * t
    | `Join of t * t
]

(* for simple printing *)
val to_string : t -> string

(* conversion to sql string *)
val to_sql : t -> string

(* evaluate over a scene *)
val evaluate : Scene.t -> t -> Table.t option
