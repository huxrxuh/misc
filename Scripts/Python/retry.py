#!/usr/bin/env python3
"""
    A robust retry decorator with exeception handling.
"""

import functools
import time

def retry(attempts=3, delay=1):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            last_exception = None
            for i in range(attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    last_exception = e
                    print(f"Attempt {i + 1} failed. Retrying in {delay} seconds...")
                    time.sleep(delay)

            # All attempts failed
            print("Max attempts reached. Aborting.")
            raise last_exception
        return wrapper
    return decorator

@retry(attempts=3, delay=2)
def unstable_network_call():
    print("Trying to connect...")
    import random
    if random.choice([True, False]):
        raise ConnectionError("Server unavailable")
    return "Success!"

try:
    print(unstable_network_call())
except ConnectionError:
    print("The connection finally failed.")
