type t

val of_json : Yojson.Basic.t -> t option
val to_json : t -> Yojson.Basic.t

val to_string : t -> string

val evaluate : t -> Core.Scene.t -> Table.t option