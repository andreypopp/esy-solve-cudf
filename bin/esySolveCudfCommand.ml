module Solver = struct
  let runWithFilename
    ?(timeout=5.) ?(strategy="-notuptodate")
    filenameIn filenameOut
    =
    match Cudf_parser.load_from_file filenameIn with
    | exception Cudf_parser.Parse_error (message, (ls, _le)) ->
      let message =
        Printf.sprintf "%s (at line %i)" message ls.Lexing.pos_lnum
      in
      `Error (false, message)
    | preamble, univ, req ->
    let preamble =
      match preamble with
      | Some preamble -> preamble
      | None -> Cudf.default_preamble
    in
    let req =
      match req with
      | Some req -> req
      | None -> Cudf.default_request
    in
    let solution =  Mccs.resolve_cudf
      ~verbose:false
      ~timeout
      strategy
      (preamble, univ, req)
    in

    match solution with
    | Some solution ->
      let oc = open_out filenameOut in
      let out = IO.output_channel oc in
      Cudf_printer.pp_io_solution out solution;
      IO.flush out;
      IO.close_out out;
      close_out oc;
      `Ok ()
    | None ->
      let oc = open_out filenameOut in
      output_string oc "\n";
      close_out oc;
      `Ok ()
end

module CommandLineInterface = struct
  open Cmdliner

  let exits = Term.default_exits
  let docs = Manpage.s_common_options
  let sdocs = Manpage.s_common_options
  let version = "0.1.0"

  let timeout =
    let doc = "Specifies timeout." in
    Arg.(
      value
      & opt (some float) None
      & info ["timeout"; "t"] ~docs ~doc
    )

  let strategy =
    let doc = "Specifies optimization criteria to use." in
    Arg.(
      value
      & opt (some string) None
      & info ["strategy"; "s"] ~docs ~doc ~docv:"STRATEGY"
    )

  let filenameIn =
    let doc = "Path to CUDF document file to solve." in
    Arg.(
      required
      & pos 0  (some file) None
      & info [] ~doc ~docv:"INPUT.CUDF"
    )

  let filenameOut =
    let doc = "Path to CUDF solution file to print to generate." in
    Arg.(
      required
      & pos 1  (some string) None
      & info [] ~doc ~docv:"OUTPUT.CUDF"
    )

  let defaultCommand =
    let doc = "Solve CUDF dependency problem" in
    let info = Term.info "esy-solve" ~version ~doc ~sdocs ~exits in
    let cmd timeout strategy filenameIn filenameOut = 
      Solver.runWithFilename ?timeout ?strategy filenameIn filenameOut
    in
    Term.(ret (const cmd $ timeout $ strategy $ filenameIn $ filenameOut)), info

  let run () =
    Printexc.record_backtrace true;
    Term.(exit (eval ~argv:Sys.argv defaultCommand))
end

let () = CommandLineInterface.run()
