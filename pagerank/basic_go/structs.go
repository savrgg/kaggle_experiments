package main

import "fmt"

type Person struct {
    Name string
    Age  int
}

func main() {
    person := Person{Name: "Alice", Age: 30}
    fmt.Println(person.Name)
    fmt.Println(person.Age)
}
