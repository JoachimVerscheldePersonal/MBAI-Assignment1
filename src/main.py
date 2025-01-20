import clingo
import random
import time
import os
from typing import Sequence

CSV_FILENAME = "data/results.csv"

class Context:
    

    def sample_vertices(self, n_vertices: clingo.Symbol, sample_size: clingo.Symbol, exclude_vertex: clingo.Symbol):
        vertices = [f'v{number}' for number in range(1,n_vertices.number+1) if number != exclude_vertex.number]
        return [clingo.String(vertex) for vertex in random.sample(vertices, sample_size.number)]

    def vertices(self, n_vertices: clingo.Symbol):
        return [clingo.String(f'v{number}') for number in range(1,n_vertices.number+1)]
    
    def edges(self,
              n_vertices: clingo.Symbol,
              max_group_size: int = 5,
              p_intra: float = 0.05,
              min_weight: int = 1,
              max_weight: int = 10):
        """
        Generates a random list of directed, weighted edges among 'n_vertices' vertices,
        attempting to represent a "street-like" graph:
          1. A global cycle over all vertices (ensures overall strong connectivity).
          2. Partition into groups with small group-local cycles.
          3. Add random edges within and across groups based on probabilities.
        
        :param n_vertices: Number of vertices (clingo.Symbol).
        :param max_group_size: Max size of each group when partitioning.
        :param p_intra: Probability of adding extra edge within a group.
        :param p_inter: Probability of adding extra edge from one group to another.
        :param min_weight: Minimum weight of an edge.
        :param max_weight: Maximum weight of an edge.
        :return: A list of directed edges in the form (u, v, w) as clingo Tuples.
        """
        num = n_vertices.number
        vertices = [f"v{i}" for i in range(1, num + 1)]

        # Shuffle vertices so the "global cycle" is random
        random.shuffle(vertices)

        edges_dict = {}

        # ---------------------------------------------------------------------
        # 1. CREATE A GLOBAL DIRECTED CYCLE THAT INCLUDES ALL VERTICES
        #    This ensures the graph is strongly connected at the top level.
        # ---------------------------------------------------------------------
        for i in range(num):
            u = vertices[i]
            v = vertices[(i + 1) % num]  # next vertex in the cycle
            if (u, v) not in edges_dict and (v, u) not in edges_dict:
                weight = random.randint(min_weight, max_weight)
                edges_dict[(u, v)] = weight

        # ---------------------------------------------------------------------
        # 2. PARTITION VERTICES INTO GROUPS
        # ---------------------------------------------------------------------
        groups = []
        i = 0
        while i < num:
            group_size = random.randint(1, max_group_size)
            group = vertices[i : min(i + group_size, num)]
            groups.append(group)
            i += group_size

        # ---------------------------------------------------------------------
        # 3. FOR EACH GROUP, ENSURE A SMALL GROUP-LOCAL CYCLE
        #    + ADD EXTRA INTRA-GROUP EDGES WITH PROBABILITY p_intra
        # ---------------------------------------------------------------------
        for group in groups:
            g_size = len(group)
            if g_size > 1:
                # Create a cycle local to the group
                for idx in range(g_size):
                    u = group[idx]
                    v = group[(idx + 1) % g_size]
                    if (u, v) not in edges_dict and (v, u) not in edges_dict:
                        weight = random.randint(min_weight, max_weight)
                        edges_dict[(u, v)] = weight

                # Add random intra-group edges
                for u in group:
                    for v in group:
                        if u != v and random.random() < p_intra:
                            if (u, v) not in edges_dict and (v, u) not in edges_dict:
                                weight = random.randint(min_weight, max_weight)
                                edges_dict[(u, v)] = weight

        weighted_edges = [
            clingo.Tuple_([clingo.String(u), clingo.String(v), clingo.Number(w)])
            for (u, v), w in edges_dict.items()
        ]

        return weighted_edges     
    
def on_model(m):
    print(m)

def on_finish(result: clingo.SolveResult):
    print(f" Satisfiable: {result.satisfiable}\n Exhausted: {result.exhausted}\n Interrupted: {result.interrupted}\n Unknown: {result.unknown}")

def on_unsat(seq: Sequence[int]):
    print(f'UNSAT: {seq}')


def read_file_contents(file_path, encoding='utf-8'):
    """
    Reads and returns the contents of a file.

    Parameters:
        file_path (str): The path to the file to be read.
        encoding (str, optional): The encoding to use when reading the file.
                                  Defaults to 'utf-8'.

    Returns:
        str: The contents of the file.

    Raises:
        FileNotFoundError: If the file does not exist.
        IOError: If there is an I/O error while reading the file.
    """
    try:
        with open(file_path, 'r', encoding=encoding) as file:
            content = file.read()
        return content
    except FileNotFoundError:
        print(f"Error: The file '{file_path}' does not exist.")
        raise
    except IOError as e:
        print(f"An I/O error occurred while reading '{file_path}': {e}")
        raise

def measure_execution_time(func):
    """
    A decorator that measures and prints the execution time of the wrapped function,
    and appends the run information to a CSV file in the format:
        test_id;n_steps;n_vertices;n_customers;execution_time_in_seconds
    """
    # We store the run counter as an attribute of 'func' so it persists across calls.
    func._run_counter = 0

    if not os.path.exists(CSV_FILENAME):
        with open(CSV_FILENAME, "w", encoding="utf-8") as f:
            f.write("test_id;n_steps;n_vertices;n_customers;execution_time_in_seconds\n")

    def wrapper(*args, **kwargs):
        # Increment the run counter to use as test_id
        func._run_counter += 1
        test_id = func._run_counter

        start = time.perf_counter()
        # Call the actual function
        satisfiable = func(*args, **kwargs)
        # Stop the timer
        end = time.perf_counter()

        # Extract relevant parameters from kwargs
        n_steps = kwargs.get("n_steps", None)
        n_vertices = kwargs.get("n_vertices", None)
        n_customers = kwargs.get("n_customers", None)

        execution_time = end - start
        print(f"{func.__name__} took {execution_time:.6f} seconds to execute.")

        if satisfiable:
            with open(CSV_FILENAME, "a", encoding="utf-8") as f:
                f.write(f"{test_id};{n_steps};{n_vertices};{n_customers};{execution_time}\n")

        return satisfiable

    return wrapper

@measure_execution_time
def run_with_params(n_vertices, n_customers, n_steps):

    ctl = clingo.Control([f"-c n_vertices={n_vertices}", f"-c n_customers={n_customers}", f"-c n={n_steps}"])
    ctl.add("base", [], program=read_file_contents("src/program.lp"))
    ctl.ground([("base", [])], context=Context())    
    result = ctl.solve(on_finish=on_finish, on_unsat=on_unsat)
    return result.satisfiable

def main():
    n_vertices_params = [10, 20, 50, 100, 200, 500, 1000]
    n_steps_params = [10, 20, 30, 50, 100, 200, 500]
    n_customer_params = [2, 3, 5, 10]

    # Nested loops: only call run_with_params when n_steps > n_vertices
    for n_vertices in n_vertices_params:
        for n_steps in n_steps_params:
            if n_vertices > n_steps:
                for n_customers in n_customer_params:
                    if n_vertices > n_customers:
                        print(f"\n=== Running with parameters: n_vertices={n_vertices}, n_steps={n_steps}, n_customers={n_customers} ===")
                        run_with_params(n_vertices= n_vertices, n_customers=n_customers, n_steps=n_steps)

# Run the main function
if __name__ == "__main__":
    main()