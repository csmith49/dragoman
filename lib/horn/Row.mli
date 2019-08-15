(* rows map variables to object indexes *)
type t

(* simple access *)
val get : t -> Variable.t -> int option
val variables : t -> Variable.t list

(* construction *)
val singleton : Variable.t -> int -> t
val of_list : (Variable.t * int) list -> t
val to_list : t -> (Variable.t * int) list

(* manipulation *)
val project : t -> Variable.t list -> t option
val rename : t -> (Variable.t * Variable.t) list -> t
val join : t -> t -> t option