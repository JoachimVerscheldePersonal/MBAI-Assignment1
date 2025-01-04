import clingo
import random
from typing import Sequence

class Context:
    
    def sample_vertices(self, n_vertices: clingo.Symbol, sample_size: clingo.Symbol, exclude_vertex: clingo.Symbol):
        vertices = [f'v{number}' for number in range(1,n_vertices.number+1) if number != exclude_vertex.number]
        return [clingo.String(vertex) for vertex in random.sample(vertices, sample_size.number)]

    def vertices(self, n_vertices: clingo.Symbol):
        return [clingo.String(f'v{number}') for number in range(1,n_vertices.number+1)]
    
    def edges(self,
              n_vertices: clingo.Symbol,
              max_group_size: int = 3, 
              p_intra: float = 0.3, 
              p_inter: float = 0.1,
              min_weight: int = 1,
              max_weight: int = 10):
        """
        Generates a random list of directed, weighted edges among 'n_vertices' vertices,
        ensuring the entire graph is strongly connected (every vertex can reach every other vertex).
        
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
        # 2. PARTITION VERTICES INTO GROUPS AND ADD EXTRA EDGES
        # ---------------------------------------------------------------------
        # Partition the vertices into groups of random size up to max_group_size
        groups = []
        i = 0
        while i < num:
            group_size = random.randint(1, max_group_size)
            group = vertices[i : min(i + group_size, num)]
            groups.append(group)
            i += group_size
        
        # Step 2A: Within each group, ensure a small cycle just for that group
        # (We already have a global cycle, but this adds additional connectivity.)
        for group in groups:
            g_size = len(group)
            if g_size > 1:
                # create a cycle local to the group
                for idx in range(g_size):
                    u = group[idx]
                    v = group[(idx + 1) % g_size]
                    if (u, v) not in edges_dict and (v, u) not in edges_dict:
                        weight = random.randint(min_weight, max_weight)
                        edges_dict[(u, v)] = weight
                
                # add random intra-group edges with probability p_intra
                for u in group:
                    for v in group:
                        if u != v and random.random() < p_intra:
                            if (u, v) not in edges_dict and (v, u) not in edges_dict:
                                weight = random.randint(min_weight, max_weight)
                                edges_dict[(u, v)] = weight
        
        # Step 2B: Add random inter-group edges with probability p_inter
        for g1 in range(len(groups)):
            for g2 in range(len(groups)):
                if g1 == g2:
                    continue
                for u in groups[g1]:
                    for v in groups[g2]:
                        if u != v and random.random() < p_inter:
                            if (u, v) not in edges_dict and (v, u) not in edges_dict:
                                weight = random.randint(min_weight, max_weight)
                                edges_dict[(u, v)] = weight
        
        # Convert edges_dict to list of clingo tuples
        weighted_edges = [
            clingo.Tuple_([clingo.String(u), clingo.String(v), clingo.Number(w)])
            for (u, v), w in edges_dict.items()
        ]
        return weighted_edges
        
    
def on_model(m):
    print(m)

def on_finish(result: clingo.SolveResult):
    print(f" Satisfiable: {result.satisfiable}\n Exhausted: {result.exhausted}\n Interrupted: {result.interrupted}\n Unknown: {result.unknown}")

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
program = read_file_contents("src/program.lp")

ctl = clingo.Control()
ctl.add("base", [],program=program)

ctl.ground([("base", [])], context=Context())
ctl.solve(on_model=on_model, on_finish=on_finish)

