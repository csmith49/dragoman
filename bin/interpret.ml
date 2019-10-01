let input_filename = ref ""
let output_filename = ref ""
let verbose = ref false
let test = ref false

(* spec list *)
let spec = [
    ("-i", Arg.Set_string input_filename, " Path to input problem file") ;
    ("-o", Arg.Set_string output_filename, " Path to output file");
    ("-v", Arg.Set verbose, " Enables verbose output");
    ("-t", Arg.Set test, " Enables testing (when no output file provided)")
]

(* parse the command line arguments *)
let anon_fun _ = ()
let usage_msg = "Interprets Horn clauses over CLEVR scenes"
let _ = Arg.parse spec anon_fun usage_msg

(* setting up verbose output *)
let vprint str = if !verbose then print_endline str else ()

(* load the input file *)
let _ = vprint "Loading problem..."
let problem = Yojson.Basic.from_file !input_filename
    |> Problem.CLEVR.of_json
    |> CCOpt.get_exn

let _ = vprint ("Evaluating " ^ (Horn.Clause.to_string problem.clause) ^ "...")
let query = Horn.Clause.to_query problem.clause
let table = Core.Query.evaluate problem.store query |> CCOpt.get_exn

let _ = vprint "Writing output..."
let _ = if !output_filename = "" 
    then 
    
        if !test then match problem.expected with
            | Some e -> if Core.Table.equal table e 
                then print_endline "[OK]"
                else print_endline "[FAIL]"
            | None -> print_endline "[NO EXPECTATION]"
        else table |> Core.Table.to_csv |> print_endline
    else CCIO.with_out 
            !output_filename 
            (fun oc -> CCIO.write_line oc (table |> Core.Table.to_csv))

let _ = vprint "Done."