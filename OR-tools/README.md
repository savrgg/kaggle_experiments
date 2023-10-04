# Google OR-Tools Linear Programming Example

This repository contains a simple example of solving a linear programming (LP) problem using Google OR-Tools in Python. In this example, we'll tackle a transportation problem where the goal is to minimize the cost of shipping goods from factories to warehouses while satisfying supply and demand constraints.

## Problem Description

In the transportation problem, we have:
- A cost matrix representing the transportation costs between factories and warehouses.
- Supply constraints indicating the availability of goods at each factory.
- Demand constraints specifying the requirements at each warehouse.

The objective is to find the optimal shipment plan that minimizes the total transportation cost.

## Usage

To run this example, follow these steps:

1. Clone this repository to your local machine:
```bash
git clone https://github.com/savrgg/tmp.git
```

2. Navigate to the project directory:
```bash
cd tmp
```

3. Ensure you have Google OR-Tools installed. If not, you can install it using pip:
```bash
pip install ortools
```

4. Run the Python script:
```bash
python transportation_lp.py
```

The script will solve the transportation problem and display the optimal solution.

## Result
After running the script, you will see the optimal cost and the shipment plan in the console output.

## Documentation
For more information about Google OR-Tools and its capabilities, refer to the official documentation:

Google OR-Tools Documentation

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments
This example is provided as a simple illustration of using Google OR-Tools for linear programming problems.
If you have any questions or issues, please don't hesitate to open an issue.



