# How to figure out current MTU

```shell
ip addr show eth0 | grep mtu
```

# How to test connection

```shell
ping -M do -s 1352 google.com
```

Test lowering by 20 bytes to find the sweet spot. Add 28 bytes that serve as the header.

# Make change permanent in WSL

First open `wsl.conf`

```shell
sudo nano /etc/wsl.conf
```
Then add this lines:

```yaml
[boot]
command = "ip link set dev eth0 mtu 1380"
```


