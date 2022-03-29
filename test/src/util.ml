let gc () =
  Gc.compact ();
  Gc.minor ();
  Gc.full_major ()

let check_leaks f =
  let () = gc () in
  let stat = (Gc.stat ()).live_blocks in
  let r = f () in
  let () = gc () in
  let stat1 = (Gc.stat ()).live_blocks in
  if stat1 > stat then
    Printf.printf "Potential GC leak detected: %d, %d\n" stat stat1;
  assert (stat >= stat1);
  r

let tests = ref []

let test ?(leak_check = true) name f =
  let open Alcotest in
  let t = [test_case name `Quick (fun () ->
    let ok = if leak_check then check_leaks f else f () in
    check bool name true ok
  )] in
  tests := (name, t) :: !tests

let run name =
  let open Alcotest in
  run ~and_exit:false name (List.rev !tests);
  tests := []
