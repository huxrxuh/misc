#!/usr/bin/env python3
"""
    The repeat function takes num_times as an argument. Inside, decorator_repeat.
    Inside that, the wrapper which runs the original function in a loop.
"""

import functools

def repeat(num_times):
    def decorator_repeat(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for _ in range(num_times):
                result = func(*args, **kwargs)
            return result
        return wrapper
    return decorator_repeat

@repeat(3)
def greet(name):
    print(f"Hello, {name}!")

greet("Alice")

# To make the assignment manually
# my_configured_decorator = repeat(num_times = 3)
# greet = my_configured_decorator(greet)
# greet("Alice")
