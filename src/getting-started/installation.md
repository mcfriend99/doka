# Installation

Doka is a nyssa pakcage and needs to be installed with Nyssa.

```
nyssa install -g doka
```

## Requirements

- Blade version v0.0.86 or above (you can check your Blade installation 
  version by running `blade -v`).

## Starting a new project

The easiest way to start a new project is by running the `create` command and 
specifying the root and/or name of the application.

```
doka create -r <root directory> 
```

Here we ran the create command and specified the name of our root directory. 
If the name of the root directory was not specified, the project will be stored 
in the current working directory. We can also specify a name for the scaffolded 
project using the `--name` (or `-n` argument). For example

```
doka create -r <root directory> -n "The next big thing"
```

If you run the `create` command without specifying the root directory or name, 
an application with the name of the current directory will be created in the 
current directory.

## Project structure

When you create a new project, the following project structure will be created:

```
<root direcoty>
|-- _data
|   |-- config.json
|   |-- sitemap.json
|-- src
|   |-- index.md
```

#### Here's what each file and directory mean.

- `/_data/`: This directory houses all configuration and sitemap files for all 
  Doka projects.
  - `config.json`: This is the main application configuration file.
  - `sitemap.json`: This is the sitemap.
- `/_src/`: This is where the contents of your website goes into.
  - `index.md`: This is a sample application page &mdash; the home page.

## Existing projects

As you'll notice, what makes up a Doka project is quite thin. For this reason, 
any existing project can simply manually create the file structure and it will 
be a valid Doka project. Try it out in one of your projects right now to see 
how easy it is to add Doka to an existing project.

> You'll achieve the same by simply running `doka create` but we believe the 
> excercise will be worth it.

## Running the development server

To preview your changes as you edit the files, you can run the development 
server that will serve your website and reflect the latest changes.

```
cd <root directory>
doka start -d
```

Now you can open a new browser window at [http://localhost:4000](http://localhost:4000).

Congratulations! You have just created your first Doka site! Browse around the 
site to see what's available.

> It's important to know that Doka can also start a production server when you 
> are ready.
