type relation_key = string

type selector = [
    | `Equal of Variable.t * Variable.t
    | `EqualConst of Variable.t * Value.t
    | `And of selector * selector
    | `Or of selector * selector
]

type t = [
    | `Relation of relation_key
    | `Select of selector * t
    | `Project of Variable.t list * t
    | `Rename of Variable.Mapping.t * t
    | `Join of t * t
    | `Empty
]

(* utility module holding useful variables *)
module X : sig
    val left : Variable.t
    val right : Variable.t
end

(* for simple printing *)
val to_string : t -> string

(* conversion to sql string *)
val to_sql : t -> string

(* evaluate over a scene *)
val evaluate : Store.t -> t -> Table.t option
