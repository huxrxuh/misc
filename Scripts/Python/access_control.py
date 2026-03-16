#!/usr/bin/env python3
"""
    Shows how decorators control the flow of a program by deciding whether to call the function at all.
"""

user_is_logged_in = False

def require_auth(func):
    def wrapper(*args, **kwargs):
        if not user_is_logged_in:
            print("Access is denied: Please log in first.")
            return None
        return func(*args, **kwargs)
    return wrapper

def delete_database():
    print("Database deleted.")
    
delete_database = require_auth(delete_database)

delete_database()

user_is_logged_in = True

delete_database()