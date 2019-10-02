(** Database allows for easy connection and manipulation of SQLite3 database files *)

(** [t] is a database connection *)
type t

(** Translations allow us to access a variety of database schemas with mostly the same code *)
module Translation : sig
    (** maps relation keys to expected column names *)
    type t

    (** expected column names *)
    type column_names = (Core.Variable.t * Core.Variable.t)

    (** [column_names t rk] gives a pair [(x, y)] representing the expected name of the left and right columns *)
    val column_names : t -> Core.Store.relation_key -> column_names option

    (** [of_view view] converts relations and attributes of view to match a standard encoding *)
    val of_view : attributes:column_names -> relations:column_names -> View.t -> t
end

(** [connect view filename] opens a database connection *)
val connect : View.t -> 
    attributes:Translation.column_names -> 
    relations:Translation.column_names -> 
    filename:string -> 
        t

(** SQL conversion *)
val to_sql : Translation.t -> Core.Query.t -> string

(** Evaluate *)
val evaluate : t -> Core.Query.t -> Core.Table.t option

(** Convert to a (local) store *)
val store : t -> Core.Value.t -> size:int -> Core.Store.t
