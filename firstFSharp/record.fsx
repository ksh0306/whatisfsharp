type Person = 
  {
    Name : string
    Age : int
  }

let person = 
  {
    Name = "Aron"
    Age = 169
  }

printfn "%A" person

let olderPerson = 
  { person with Age = person.Age + 2 }
printfn "%A" olderPerson
