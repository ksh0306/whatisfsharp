let numbers = [2; 3; 4]
let newnums = 1 :: numbers
printfn "%A, %A" numbers newnums

let uninums = newnums @ numbers
printfn "%A" uninums

let doubled =
  uninums
  |> List.map(fun x -> x * 2)
printfn "%A" doubled
let rlt = 
  doubled
  |> List.filter(fun x -> x > 5)
  |> List.sum
printfn "%d" rlt
