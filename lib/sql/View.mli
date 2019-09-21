type t

val of_json : Yojson.Basic.t -> t option

val attributes : t -> Core.Thing.attribute list
val relations : t -> Core.Scene.relation list