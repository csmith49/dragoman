(* translation *)

module Translation = struct
    module KeyMap = CCMap.Make(CCString)
    
    type column_names = (Core.Variable.t * Core.Variable.t)
    type t = column_names KeyMap.t

    let column_names trans rk = KeyMap.get rk trans

    let of_view ~attributes ~relations view =
        let attribute_assoc = view
            |> View.attributes
            |> CCList.map (fun attr -> (attr, attributes)) in
        let relation_assoc = view
            |> View.relations
            |> CCList.map (fun rel -> (rel, relations)) in
        KeyMap.of_list (attribute_assoc @ relation_assoc)
end

(* basics *)

type t = {
    db : Sqlite3.db;
    view : View.t;
    translation : Translation.t;
}

let connect view ~attributes ~relations ~filename = {
    db = Sqlite3.db_open filename;
    view = view;
    translation = Translation.of_view ~attributes ~relations view;
}

(* sql converesion *)

let mk = Printf.sprintf

let rec selector_to_sql = function
    | `Equal (x, y) -> mk
        "%s = %s"
        (Core.Variable.to_string x)
        (Core.Variable.to_string y)
    | `EqualConst (x, v) -> mk
        "%s = %s"
        (Core.Variable.to_string x)
        (Core.Value.to_string v)
    | `And (l, r) -> mk
        "(%s) AND (%s)"
        (selector_to_sql l)
        (selector_to_sql r)
    | `Or (l, r) -> mk
        "(%s) OR (%s)"
        (selector_to_sql l)
        (selector_to_sql r)

let rec to_sql trans = function
    | `Relation rk -> begin match Translation.column_names trans rk with
        | Some (left, right) -> mk
            "SELECT %s AS left, %s AS right FROM %s"
            (Core.Variable.to_string left)
            (Core.Variable.to_string right)
            rk
        | None -> mk "SELECT * FROM %s" rk end
    | `Select (s, q) -> mk
        "SELECT * FROM (%s) WHERE %s"
        (to_sql trans q)
        (selector_to_sql s)
    | `Project (xs, q) -> mk
        "SELECT %s FROM (%s)"
        (xs |> CCList.map Core.Variable.to_string |> CCString.concat ", ")
        (to_sql trans q)
    | `Rename (m, q) -> mk
        "SELECT %s FROM (%s)"
        (m 
            |> CCList.map (fun (x, y) -> mk
                "%s AS %s"
                (Core.Variable.to_string x)
                (Core.Variable.to_string y))
            |> CCString.concat ", ")
        (to_sql trans q)
    | `Join (l, r) -> mk 
        "SELECT * FROM ((%s) JOIN (%s))"
        (to_sql trans l)
        (to_sql trans r)
    | `Empty -> "()"

(* evaluate *)
let header_to_variables (headers : Sqlite3.headers) : Core.Variable.t list = headers
    |> CCArray.to_list
    |> CCList.map Core.Variable.of_string

let row_to_values (row : Sqlite3.row_not_null) : Core.Table.row = row
    |> CCArray.to_list
    |> CCList.map Core.Value.of_string

let evaluate db query =
    (* construct the query for the databse *)
    let sql_query = to_sql db.translation query in
    (* set up the mutable memory needed for the callback *)
    let keys = ref [] in
    let rows = ref [] in
    (* construct the callback *)
    let callback row header =
        rows := (row_to_values row) :: !rows;
        if CCList.is_empty !keys then keys := (header_to_variables header); in
    let _ = Sqlite3.exec_not_null db.db ~cb:callback sql_query in
    Core.Table.of_list !keys !rows
    
(* get a store *)
let store _ _ ~size:_ = Core.Store.empty
