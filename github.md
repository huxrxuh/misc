# Github

## Initialize and link a repo

```shell
git init
git remote add origin LINK-TO-REPO
```

```shell
git fetch
git checkout -b main
```

If there are files we need to keep:

```shell
git pull origin main --allow-unrelated-histories
```

Need to solve conflicts if any.

Then this is ready for a new commit:

```shell
git add .
git commit -m MESSAGE
git push -u origin main
```

## Initialize a repo and create the remote

```shell
git init
git add .
git commit -m "COMMIT MESSAGE"
```

Then create the remote and copy the link.

### Link and push


```shell
git remote add origin LINK-TO-REPO
git branch -M main
git push -u origin main
```

## Sync with and existing branch

Sync with existing branch (locally and remote):

```shell
git checkout BRANCH
git remote add origin LINK
git fetch
git pull origin BRANCH --allow-unrelated-histories
```

## Sync with new branch

To sync with a new branch:

```shell
git checkout -b NEW-BRANCH
git add .
git commit -m MESSAGE
git remote add origin LINK
git push -u origin NEW-BRANCH
```
```
