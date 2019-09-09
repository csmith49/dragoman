(* abstract table type *)
type t

(* construction *)
val empty : Variable.t list -> t
val of_list : Variable.t list -> (int list) list -> t option

(* getters *)
val get : Variable.t -> t -> (int list) option

(* manipulation stuff *)
val join_all : t list -> t

(* comparison *)
val equal : t -> t -> bool

(* i/o *)
val to_csv : ?delimiter:string -> t -> string
val of_json : Yojson.Basic.t -> t option