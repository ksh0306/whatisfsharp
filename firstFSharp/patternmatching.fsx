let describeNumber x =
  match x with
  | 0 -> "Zero"
  | 1 -> "One"
  | n when n > 1 -> "More than One"
  | _ -> "Negative"

printfn "%s" (describeNumber -3)
