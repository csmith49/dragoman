(* abstract table type *)
type t
type row = Index.t list
type column = Index.t list

(* construction *)
val empty : Variable.t list -> t
val of_list : Variable.t list -> row list -> t option

(* getters *)
val get : Variable.t -> t -> column option

(* manipulation stuff *)
val join_all : t list -> t

(* comparison *)
val equal : t -> t -> bool

(* i/o *)
val to_csv : ?delimiter:string -> t -> string
val of_json : Yojson.Basic.t -> t option