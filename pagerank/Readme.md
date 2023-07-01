# PageRank Implementation in Go

This repository contains an implementation of the PageRank algorithm in Go. The PageRank algorithm is used to rank the importance of nodes in a graph based on their connectivity. It has been widely used by search engines to determine the relevance and popularity of web pages.

## Algorithm Overview

The PageRank algorithm follows the following steps:

1. Initialize the rank of each node to an equal probability.
2. Iterate through the nodes and update their ranks based on the ranks of the nodes they are connected to.
3. Repeat step 2 until the ranks converge or a maximum number of iterations is reached.
4. The final ranks represent the importance of each node in the graph.

## Usage

To use the PageRank implementation, follow these steps:

1. Install Go on your machine. You can download it from the official Go website: https://golang.org/
2. Clone this repository to your local machine.
3. Update the graph in the `main.go` file to represent your desired graph structure.
4. Run the program using the command `go run main.go graph.go node.go`.

## Example

Here's an example graph representation in the `main.go` file:

```go
graph := NewGraph()
graph.AddNode("A", []string{"B", "C"})
graph.AddNode("B", []string{"C"})
graph.AddNode("C", []string{"A"})