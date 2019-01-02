# sam-build-yarn

Command to build AWS SAM apps that use nodejs with `yarn`.

Supports local file dependencies, and matches the `sam build` command output so you can use the `sam-build-yarn` command as a replacement for `sam build`.

**NOTE:** Currently _does not_ support building using a container e.g. `sam build --container`

## New Features:

- Specify commands to run before building in a function by including a `sam:prebuild` script in the `package.json`.

## Installation

AWS SAM Yarn Builder is a ruby gem, so you can install it using this command:

    $ gem install aws-sam-yarn-builder

## Usage

Execute:

    $ sam-build-yarn

Assumes the template is located at the root of the project and named `template.yml`. You can specify a different template file like so:

    $ sam-build-yarn --template-file ./samapp.yaml

### Example App

For an example of how this builder can work, here is the layout of an example SAM app with a single function (under `src`) with a local nodejs dependency (under `lib`):

```
sam-app/
├── lib/
│   └── local-dependency/
│       ├── index.js
│       └── package.json
└── src/
    └── hello-world/
        ├── app.js
        └── package.json
```

The `hello-world/package.json` contents look like this:

```json
{
  "name": "hello_world",
  "version": "1.0.0",
  "dependencies": {
    "local-file-dependency": "file:../../lib/local-file-dependency"
  }
}
```

With this layout and setup, you would not be able to build with `sam build` because it doesn't support dependencies that point to a file on the local filesystem.

`sam-build-yarn` will inspect all function package.json files for local file dependencies and "stage" them into the build before building each function, overriding the dependencies path in the package.json to point to the staged one.

The result of the build after running `sam-build-yarn` matches that of `sam build`:

```
sam-app/
├── .aws-sam/
│   └── build/
│       ├── HelloWorldFunction/
│       │   ├── node_modules/
│       │   ├── app.js
│       │   ├── package.json
│       │   └── yarn.lock
│       └── template.yaml
├── lib/
│   └── local-dependency/
│       ├── index.js
│       └── package.json
└── src/
    └── hello-world/
        ├── app.js
        └── package.json
```
