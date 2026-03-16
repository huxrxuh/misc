#!/usr/bin/env python3
"""
    The script modifies the output of the original function.
"""

def shout(func):
    def wrapper(*args, **kwargs):
        result = func(*args, **kwargs)
        return result.upper() + "!!!"
    return wrapper

@shout
def greet(name):
    return f"hello {name}"

print(greet("world"))
        
