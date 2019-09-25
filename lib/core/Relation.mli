type index = int
type t

val to_string : t -> string
val of_json : Yojson.Basic.t -> t option

val of_list : (index * index) list -> t
val to_list : t -> (index * index) list