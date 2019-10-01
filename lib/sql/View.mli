type t

val of_json : Yojson.Basic.t -> t option

val attributes : t -> Core.Store.relation_key list
val relations : t -> Core.Store.relation_key list