type t

val empty : Variable.t list -> t
val join_all : t list -> t
val of_list : Variable.t list -> (int list) list -> t option
val to_csv : ?delimiter:string -> t -> string