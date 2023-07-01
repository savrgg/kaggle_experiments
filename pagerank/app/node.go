package main

type Node struct {
	ID    string
	Edges []string
	Rank  float64
}

type Graph struct {
	Nodes []*Node
}

