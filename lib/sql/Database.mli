type t

val of_file : string -> t

val evaluate : t -> Query.t -> Core.Table.t option

val scene : t -> Core.Scene.index -> View.t -> int -> Core.Scene.t