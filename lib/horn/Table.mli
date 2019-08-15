type t

(* access *)
val get : t -> Variable.t -> int list option
val variables : t -> Variable.t list
val rows : t -> Row.t list

(* construction *)
val empty : t
val of_row : Row.t -> t
val add_row : t -> Row.t -> t option
val of_list : Row.t list -> t option

(* manipulation *)
val project : t -> Variable.t list -> t option
val rename : t -> (Variable.t * Variable.t) list -> t
val join : t -> t -> t
val filter : t -> (Row.t -> bool) -> t