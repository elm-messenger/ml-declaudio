open Js_of_ocaml

type volume_timelines = (float * float) list list

let gen_volume_timelines : volume_timelines -> Js.Unsafe.any =
 fun vts ->
  let timeline_to_js (timeline : (float * float) list) =
    let points =
      Array.map
        (fun (t, v) ->
          Js.Unsafe.obj
            [|
              ("time", Js.Unsafe.inject (Js.float t));
              ("volume", Js.Unsafe.inject (Js.float v));
            |])
        (Array.of_list timeline)
    in
    Js.array points
  in
  let timelines_js = List.map timeline_to_js vts in
  Js.Unsafe.inject (Js.array (Array.of_list timelines_js))

let stop_sound (node_id : int32) =
  Js.Unsafe.obj
    [|
      ("action", Js.Unsafe.inject (Js.string "stopSound"));
      ("nodeGroupId", Js.Unsafe.inject (Js.int32 node_id));
    |]

let set_volume (node_id : int32) (volume : float) =
  Js.Unsafe.obj
    [|
      ("action", Js.Unsafe.inject (Js.string "setVolume"));
      ("nodeGroupId", Js.Unsafe.inject (Js.int32 node_id));
      ("volume", Js.Unsafe.inject (Js.float volume));
    |]

let set_volume_at (node_id : int32) (volumeat : volume_timelines) =
  Js.Unsafe.obj
    [|
      ("action", Js.Unsafe.inject (Js.string "setVolumeAt"));
      ("nodeGroupId", Js.Unsafe.inject (Js.int32 node_id));
      ("volumeAt", gen_volume_timelines volumeat);
    |]

type loop_config = { loop_start : float; loop_end : float }

let get_loop_start (cfg : loop_config option) : Js.Unsafe.any =
  match cfg with
  | Some c -> Js.Unsafe.inject @@ Js.float c.loop_start
  | None -> Js.Unsafe.inject Js.null

let get_loop_end (cfg : loop_config option) : Js.Unsafe.any =
  match cfg with
  | Some c -> Js.Unsafe.inject @@ Js.float c.loop_end
  | None -> Js.Unsafe.inject Js.null

let set_loop_config (node_id : int32) (loop : loop_config option) =
  Js.Unsafe.obj
    [|
      ("action", Js.Unsafe.inject (Js.string "setLoopConfig"));
      ("nodeGroupId", Js.Unsafe.inject (Js.int32 node_id));
      ("loopStart", get_loop_start loop);
      ("loopEnd", get_loop_end loop);
    |]

let set_playback_rate (node_id : int32) (playback_rate : float) =
  Js.Unsafe.obj
    [|
      ("action", Js.Unsafe.inject (Js.string "setPlaybackRate"));
      ("nodeGroupId", Js.Unsafe.inject (Js.int32 node_id));
      ("playbackRate", Js.Unsafe.inject (Js.float playback_rate));
    |]

let start_sound (node_id : int32) (buffer_id : int32) (volume : float)
    (volume_timelines : volume_timelines) (start_time : int32)
    (start_at : float) (loop : loop_config option) (playback_rate : float) =
  Js.Unsafe.obj
    [|
      ("action", Js.Unsafe.inject (Js.string "startSound"));
      ("nodeGroupId", Js.Unsafe.inject (Js.int32 node_id));
      ("bufferId", Js.Unsafe.inject (Js.int32 buffer_id));
      ("startTime", Js.Unsafe.inject (Js.int32 start_time));
      ("volume", Js.Unsafe.inject (Js.float volume));
      ("volumeTimelines", gen_volume_timelines volume_timelines);
      ("startAt", Js.Unsafe.inject (Js.float start_at));
      ("loopStart", get_loop_start loop);
      ("loopEnd", get_loop_end loop);
      ("playbackRate", Js.Unsafe.inject (Js.float playback_rate));
    |]

let load_audio (audio_url : string) (req_id : int32) =
  Js.Unsafe.obj
    [|
      ("audioUrl", Js.Unsafe.inject (Js.string audio_url));
      ("requestId", Js.Unsafe.inject (Js.int32 req_id));
    |]
