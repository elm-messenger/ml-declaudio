(* Core types from Audio.elm *)

(** Buffer identifier wrapper *)
type buffer_id = BufferId of int32

(** Audio source data *)
type source = File of { buffer_id : buffer_id }

(** Loop configuration *)
type loop_config = { loop_start : float; loop_end : float }

(** Audio playback configuration *)
type play_audio_config = {
  loop : loop_config option;
  playback_rate : float;
  start_at : float;  (* Duration in seconds *)
}

(** Audio effects *)
type effect_type =
  | ScaleVolume of { scale_by : float }
  | ScaleVolumeAt of { volume_at : (float * float) list }  (* (time, volume) list *)
  | Offset of float  (* Duration offset in seconds *)

(** Main audio type *)
type audio =
  | Group of audio list
  | BasicAudio of {
      source : source;
      start_time : int32;  (* Unix timestamp in milliseconds *)
      settings : play_audio_config;
    }
  | Effect of {
      effect_type : effect_type;
      audio : audio;
    }

(** Volume timeline type (non-empty list of (time, volume) points) *)
type volume_timeline = (float * float) list

(** Volume timelines (list of volume timelines) *)
type volume_timelines = volume_timeline list

(** Audio loading errors *)
type load_error =
  | FailedToDecode
  | NetworkError
  | UnknownError
  | ErrorThatHappensWhenYouLoadMoreThan1000SoundsDueToHackyWorkAroundToMakeThisPackageBehaveMoreLikeAnEffectPackage

(* Helper functions *)

(** Extract raw buffer ID from buffer_id wrapper *)
val raw_buffer_id : buffer_id -> int32

(** Default audio playback configuration *)
val audio_default_config : play_audio_config

(** Create audio from source with default configuration *)
val audio : source -> int32 -> audio

(** Create audio from source with custom configuration *)
val audio_with_config : play_audio_config -> source -> int32 -> audio

(** Scale volume of audio *)
val scale_volume : float -> audio -> audio

(** Scale volume at specific time points *)
val scale_volume_at : (float * float) list -> audio -> audio

(** Offset audio by duration *)
val offset_by : float -> audio -> audio

(** Combine multiple audio items into a group *)
val group : audio list -> audio

(** Create silence (empty audio group) *)
val silence : audio

val stop_sound : int32 -> Js_of_ocaml.Js.Unsafe.any
val set_volume : int32 -> float -> Js_of_ocaml.Js.Unsafe.any
val set_volume_at : int32 -> volume_timelines -> Js_of_ocaml.Js.Unsafe.any
val get_loop_start : loop_config option -> Js_of_ocaml.Js.Unsafe.any
val get_loop_end : loop_config option -> Js_of_ocaml.Js.Unsafe.any
val set_loop_config : int32 -> loop_config option -> Js_of_ocaml.Js.Unsafe.any
val set_playback_rate : int32 -> float -> Js_of_ocaml.Js.Unsafe.any

(* val gen_volume_timelines : volume_timelines -> Js_of_ocaml.Js.Unsafe.any *)

val start_sound :
  int32 ->
  int32 ->
  float ->
  volume_timelines ->
  int32 ->
  float ->
  loop_config option ->
  float ->
  Js_of_ocaml.Js.Unsafe.any

val load_audio : string -> int32 -> Js_of_ocaml.Js.Unsafe.any
