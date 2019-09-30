type t = Sqlite3.db

let of_file filename =
    Sqlite3.db_open filename

(* convert a sql row to a "real" row *)
let convert_row (sql_row : Sqlite3.row_not_null) : Core.Table.row option = sql_row
    |> CCArray.to_list
    |> CCList.map (Core.Value.of_string)
    |> CCOpt.return

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

(* UTILITY *)
(* module VarSet = CCSet.Make(Core.Variable)

let relation db relation ?(source=None) ?(destination=None) =
    (* fun to convert id lists to comma concatenated lists *)
    let index_set_rep ids = ids |> CCList.map Core.Index.to_string |> CCString.concat ", " in
    (* based on what is provided, generate the appropriate where clause *)
    let where_string = match (CCOpt.map index_set_rep source), (CCOpt.map index_set_rep destination) with
        | Some srcs, Some dests -> Printf.sprintf
            "WHERE source IN (%s) AND destination IN (%s)" srcs dests
        | None, Some dests -> Printf.sprintf
            "WHERE destination IN (%s)" dests
        | Some srcs, None -> Printf.sprintf
            "WHERE source IN (%s)" srcs
        | None, None -> "" in
    (* generate the query from simple string formatting *)
    let query_string = Printf.sprintf "SELECT * FROM %s %s" relation where_string in
    let query = Query.of_string query_string in
    (* evaluate and extract tuples, if at all possible *)
    match evaluate db query with
        | Some table ->
            let src = Core.Table.get (Core.Variable.of_string "source") table in
            let dest = Core.Table.get (Core.Variable.of_string "destination") table in
            begin match src, dest with
                | Some src, Some dest -> CCList.map2 (fun x -> fun y -> (x, y)) src dest
                | _ -> [] end
        | None -> []
     *)
(* TODO : finish this, must add better scene construction tools *)
(* let scene db index view size = raise (Invalid_argument "") *)
let scene _ _ _ _ = raise (Invalid_argument "no")