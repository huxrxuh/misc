# What is the SheBang

A `SheBang` (`#` hash, `!` bang) tells the OS what interpreter to use. For python scripts, the modern Shebang is:

```python
#!/usr/bin/env python3
"""
Description of the script.
"""
```

Examples:

```shell
#!/usr/bin/env bash

#!/usr/bin/env ruby

#!/usr/bin/env python3

```

By doing this, the script can be executed with `./script.py` instead of `python ./script.py`.

This is suitable for virtual environments, as the OS will force to use the interpreter active in the virtual environment.

Make sure to give executable permissions to the file by running:


```shell
chmod -x script.py
```

