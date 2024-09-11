From Perennial.program_proof Require Import grove_prelude.
From Grackle.example Require Import example.
From Perennial.program_proof Require Import marshal_stateless_proof.

(* Annotations and discussion for this file is in marshal_proof.org *)

Module encodeTimestamp.
Section encodeTimestamp.

Context `{!heapGS Σ}.

Record Timestamp :=
  mkC {
      hour : u32 ;
      minute : u32 ;
      second : u32 ;
    }.

Definition has_encoding (encoded:list u8) (args:Timestamp) : Prop :=
  encoded = (u32_le args.(hour)) ++ (u32_le args.(minute)) ++ (u32_le args.(second)).

Definition own args_ptr args q : iProp Σ :=
  "Hargs_hour" ∷ args_ptr ↦[TimeStamp :: "hour"]{q} #args.(hour) ∗
  "Hargs_minute" ∷ args_ptr ↦[TimeStamp :: "minute"]{q} #args.(minute) ∗
  "Hargs_second" ∷ args_ptr ↦[TimeStamp :: "second"]{q} #args.(second).

Lemma wp_Encode (args_ptr:loc) (args:Timestamp) (prefix:list u8) (pre_sl:Slice.t) :
  {{{
        "Hown" ∷ own args_ptr args (DfracDiscarded) ∗
        "Hpre" ∷ own_slice pre_sl byteT (DfracOwn 1) prefix
  }}}
    MarshalTimeStamp #args_ptr (slice_val pre_sl)
  {{{
        enc enc_sl, RET (slice_val enc_sl);
        ⌜has_encoding enc args⌝ ∗
        own_slice enc_sl byteT (DfracOwn 1) (prefix ++ enc)
  }}}.

Proof.
  iIntros (?) "H HΦ". iNamed "H". iNamed "Hown". wp_rec.
  wp_apply (wp_NewSliceWithCap).
  { apply encoding.unsigned_64_nonneg. }
  iIntros (?) "Hsl".
  wp_apply (wp_ref_to); first by val_ty.
  iIntros (?) "Hptr".
  wp_pures.

  wp_loadField. wp_load. wp_apply (wp_WriteInt32 with "[$]").
  iIntros (?) "Hsl". wp_store.

  wp_loadField. wp_load. wp_apply (wp_WriteInt32 with "[$]").
  iIntros (?) "Hsl". wp_store.

  wp_loadField. wp_load. wp_apply (wp_WriteInt32 with "[$]").
  iIntros (?) "Hsl". wp_store.

  wp_load. wp_apply (wp_SliceAppendSlice with "[Hpre Hsl]"); first auto.
  { iFrame. iApply own_slice_to_small in "Hsl". iFrame. }
  iIntros (?) "[Hs1 Hs2]". iApply "HΦ". iFrame. iPureIntro. done.
Qed.

Lemma wp_Decode enc enc_sl (args:Timestamp) (suffix : list u8) (q : dfrac):
  {{{
        ⌜has_encoding enc args⌝ ∗
        own_slice_small enc_sl byteT q (enc ++ suffix)
  }}}
    UnmarshalTimeStamp (slice_val enc_sl)
  {{{
        args_ptr suff_sl, RET (#args_ptr, suff_sl); own args_ptr args (DfracOwn 1) ∗
                                                    own_slice_small suff_sl byteT q suffix
  }}}.

Proof.
  iIntros (?) "[%Henc Hsl] HΦ". wp_rec.
  wp_apply wp_allocStruct; first by val_ty.
  iIntros (?) "Hs". wp_pures.
  wp_apply wp_ref_to; first done.
  iIntros (?) "Hptr". wp_pures.
  iDestruct (struct_fields_split with "Hs") as "HH".
  iNamed "HH". rewrite Henc.

  wp_load. wp_apply (wp_ReadInt32 with "[$]"). iIntros (?) "Hs".
  wp_pures. wp_storeField. wp_store.

  wp_load. wp_apply (wp_ReadInt32 with "[$]"). iIntros (?) "Hs".
  wp_pures. wp_storeField. wp_store.

  wp_load. wp_apply (wp_ReadInt32 with "[$]"). iIntros (?) "Hs".
  wp_pures. wp_storeField. wp_store.

  wp_load. wp_pures.
  iApply "HΦ". iModIntro. iFrame.
Qed.

End encodeTimestamp.
End encodeTimestamp.
