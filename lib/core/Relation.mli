type t

val to_string : t -> string
val of_json : Yojson.Basic.t -> t option

val of_list : (Value.t * Value.t) list -> t
val to_list : t -> (Value.t * Value.t) list