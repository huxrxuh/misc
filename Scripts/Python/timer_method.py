#!/usr/bin/env python3
"""
    The script measures the time taken to perform a task.
"""

import functools
import time

def timer(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        end = time.perf_counter()
        print(f"Method {func.__name__} took {end - start: .4f} seconds.")
        return result
    return wrapper

class Database:
    def __init__(self, name):
        self.name = name

    @timer
    def query(self, statement):
        print(f"Executing query on {self.name}...")
        time.sleep(1)
        return "Data result"

db = Database("MainDB")
db.query("SELECT * FROM users")
