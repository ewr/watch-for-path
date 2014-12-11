# watch\_for\_path

Wait recursively for a path to exist.

For instance, say you're creating an environment that is going to get
deployed to by Capistrano, and you want to monitor `current/tmp/restart.txt`
to know when a deployment is completed. You can't just do an `fs.watch`,
since `current/tmp` doesn't exist. `watch_for_path` will find the closest
path of the path that does exist, and will watch for your file from there.

## Usage:

```coffee

    Watch = require "watch-for-path"

    new Watch "./current/tmp/restart.txt", (err) ->
      if !err
        # File has shown up!

```

Arguments are the path to watch and a callback to fire when the path shows up.