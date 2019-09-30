(* abstract table type *)
type t
type row = Value.t list
type keyed_row = (Variable.t * Value.t) list
type column = Value.t list
type mapping = (Variable.t * Variable.t) list

(* construction *)
val empty : Variable.t list -> t
val of_list : Variable.t list -> row list -> t option
val of_relation : Relation.t -> Variable.t -> Variable.t -> t option

(* getters *)
val get : Variable.t -> t -> column option

(* manipulation stuff *)
val join : t -> t -> t
val join_all : t list -> t
val filter : (keyed_row -> bool) -> t -> t
val project : Variable.t list -> t -> t option
val rename : mapping -> t -> t

(* comparison *)
val equal : t -> t -> bool

(* i/o *)
val to_csv : ?delimiter:string -> t -> string
val of_json : Yojson.Basic.t -> t option