# Introduction

Doka helps you **create beautiful documentation sites from markdown files**
without taking the steering from your hands.

Doka is built in [Blade](https://bladelang.com) and that's all that's required to run Doka.

## Getting Started

You can install Doka from nyssa:

```
nyssa install -g doka
```

Create a new Doka site by running the commands:

```
doka create -r my-website
```

And start the site:

```
cd my-website/
doka start --dev
```

Open [http://localhost:4000](http://localhost:4000) and see your website.

Now open the file at `src/index.md` inside the `my-wesbite` folder and add some text and 
reload your browser page to see your changes. Viola!

## Features

- Simple: Markdown and JSON knowledge is all you need to create a site with 
  Doka.
- Customizable: You can customize Doka to your hearts desire with various 
  themes and theme boilerplates.
  Configurable: Everything can be configured in Doka. Even the themes.
- Search: You can search your entire website quickly.
- Fast: Doka has been built optimized for blazing speed.


## Something missing?

If you find issues with the documentation or have suggestions on how to improve the 
documentation or the project in general, please file an issue for us.

For new feature requests, you can create a new issue on our 
[Github](https://github.com/mcfriend99/doka) or make a Pull Request for new features 
if you are up for it.
