type t

val of_string : string -> t
val to_string : t -> string

val join : t -> t -> t
val join_all : t list -> t