#!/usr/bin/env python3
"""
    The script measures the time taken to perform a task.
"""

import time
def timer_decorator(func):
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()
        print(f"Function {func.__name__} took {end_time - start_time: .4f} seconds.")
        return result
    return wrapper

# Manual assignment
def compute_heavy_task(n):
    return sum(i * i for i in range(n))

compute_heavy_task = timer_decorator(compute_heavy_task)

# Calling it trigger the wrapper
print(compute_heavy_task(1000000))
