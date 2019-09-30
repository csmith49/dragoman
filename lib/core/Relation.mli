type t

val to_string : t -> string
val of_json : Yojson.Basic.t -> t option

val of_list : (Index.t * Index.t) list -> t
val to_list : t -> (Index.t * Index.t) list