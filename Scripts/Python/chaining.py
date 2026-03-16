#!/usr/bin/env python3
"""
    This script chains two decorators.
    The closes to the function definition runs first.
"""

import functools
import time

def timer(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        print(f"Time taken: {time.perf_counter() - start: .4f}s")
        return result
    return wrapper

def retry(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        print("Attempting...")
        return func(*args, **kwargs)
    return wrapper

@timer
@retry
def fetch_data():
    time.sleep(1)
    return "Data"

fetch_data()
