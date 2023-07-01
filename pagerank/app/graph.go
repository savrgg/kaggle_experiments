
package main

import (
	"fmt"
	"math"
)

func NewGraph() *Graph {
	return &Graph{}
}

func (g *Graph) AddNode(id string, edges []string) {
	node := &Node{
		ID:    id,
		Edges: edges,
		Rank:  0.0,
	}
	g.Nodes = append(g.Nodes, node)
}

func (g *Graph) PageRank(dampingFactor float64, epsilon float64, maxIterations int) {
	numNodes := len(g.Nodes)
	initialRank := 1.0 / float64(numNodes)

	// Initialize ranks with equal probability for all nodes
	for _, node := range g.Nodes {
		node.Rank = initialRank
	}

	for iteration := 0; iteration < maxIterations; iteration++ {
		maxDiff := 0.0

		// Compute the new ranks for each node
		for _, node := range g.Nodes {
			newRank := (1.0 - dampingFactor) / float64(numNodes)

			for _, edge := range node.Edges {
				numOutgoing := len(g.FindNode(edge).Edges)
				if numOutgoing > 0 {
					newRank += dampingFactor * (g.FindNode(edge).Rank / float64(numOutgoing))
				}
			}

			diff := math.Abs(newRank - node.Rank)
			if diff > maxDiff {
				maxDiff = diff
			}

			node.Rank = newRank
		}

		// Check for convergence
		if maxDiff < epsilon {
			break
		}
	}
}

func (g *Graph) FindNode(id string) *Node {
	for _, node := range g.Nodes {
		if node.ID == id {
			return node
		}
	}
	return nil
}

func (g *Graph) PrintRanks() {
	for _, node := range g.Nodes {
		fmt.Printf("Node: %s, Rank: %.4f\n", node.ID, node.Rank)
	}
}
