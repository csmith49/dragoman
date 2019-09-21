type t = Sqlite3.db

let of_file filename =
    Sqlite3.db_open filename

(* convert a sql row to a "real" row *)
let convert_row (sql_row : Sqlite3.row_not_null) : Core.Table.row option = sql_row
    |> CCArray.to_list
    |> CCList.map (CCInt.of_string)
    |> CCList.all_some

(* convert a header to a Variable list *)
let convert_header (sql_headers : Sqlite3.headers) : Core.Variable.t list option = sql_headers
    |> CCArray.to_list
    |> CCList.map (fun s -> `String s)
    |> CCList.map Core.Variable.of_json
    |> CCList.all_some

let evaluate db query =
    let keys = ref [] in
    let rows = ref [] in
    let success = ref true in
    let callback row header = match convert_header header, convert_row row with
        | Some hdr, Some row ->
            rows := row :: !rows;
            if CCList.is_empty !keys then keys := hdr;
        | _ -> success := false
    in
    let _ = Sqlite3.exec_not_null db ~cb:callback (Query.to_string query) in
    if !success then Core.Table.of_list !keys !rows else None

(* TODO : finish this, must add better scene construction tools *)
(* let scene db index view size = raise (Invalid_argument "") *)
let scene _ _ _ _ = raise (Invalid_argument "no")