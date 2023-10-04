# Configuration

Doka is a configuration first application and everything can be configured. 
There are two distinct types of configurations in Doka:

- Application Configuration
- Theme configuration

## Application Configuration

The application configuration file allows you to customize different aspects 
of your Doka app and resides in `_data/config.json` by default &mdash; Yes, 
you read that right. 

You can change where you store the application configuration at any time by 
creating a valid application configuration file with any other name and in any 
other location and pointing to it when you start or build your project using 
the `--config` (or `-c`) argument. For example,

```
doka start -d --config /path/to/my/config/something.json
```

### What goes into an application configuration file?

When you create a new Doka application, doka automatically populate a very thin 
application configuration file for you which should serve you just fine for most 
use cases. 

It is however important that you know what makes up the configuration file for 
optimal customization. This will also be beneficial for you if you are creating 
a Doka app without the `doka create` command.

Below is an example of a full application configuration:

```json
{
  "app_name": "Doka",
  "search_page": "/search",
  "root": "src/",
  "assets": "assets/",
  "cache": "_cache/",
  "sitemap": "_data/sitemap.json",
  "theme": "default",
  "silent": false,
  "dev": false
}
```

- **app_name**: The name of the Doka application.
- **search_page**: The path of the search page. The default value is `/search`. 
  This configuration allows you to override that in case you have to use `/search` 
  in your application.
- **root**: The root of the website source files. By default, this is the `src` 
  directory at the root of the application.
- **assets**: Where to serve static files from. You can store any kind of file 
  in this directory and they'll be accessible as static files that can be browsed 
  or downloaded in your website. For example, you can store stylesheets and 
  JavaScript files here.
- **cache**: Where to store application cache files such as compiled HTML output 
  and compiled sitemaps. By default, this is the `_cache` directory at the root of 
  the application.
- **sitemap**:  valid JSON file that services as the sitemap for the current 
  application (See [Sitemaps](/getting-started/sitemap)). By default, this is 
  located at `_data/sitemap.json`.
- **theme**: The name of the theme used by the applicaiton. This is by default 
  the theme `default` which comes packaged with Doka.
- **silent**: Turn on or off request logging for `doka start`. Default is `true`. 
  This configuration can also be passed in via the CLI for `doka start` command.
- **dev**: Turn on the development mode for Doka. Default is `false`. This 
  configuration can also be passed in via the CLI for `doka start` command.

> Only the `app_name` and `search_page` configuration are required.

## Theme Configuration

Most of the configuration you'll encounter while using Doka will be theme 
configurations. This is because Doka was built grounds-up to be theme friendly. 
What this means is that a theme decides and control most of what can be 
configured. This configuration is wholely dependent on the theme being used.

To customize your theme, you need to create a JSON file in `_data/<theme name>.json`. 
All configurations in this file will be passed on to your theme and override the 
theme's default values for the given configurations.

You can also override the path and name of the theme configuration file by creating 
a dynamic application configuration property named `<theme name>_config` this will 
override the file `_data/<theme name>.json`.

## Using configuration in your website.

You can access all your application configurations in your website as well as 
extend your application configurations to include almost anything you think you 
want and reuse them in your website as needed. In fact, this is highly encouraged.

To show configurations in the website, simply wrap them within the `%(` and `)` 
pair. This is valid everywhere except for within code blocks, images and links. 
For example, if you want to show the application name on a website page you can do 
something like this:

```
Welcome to %(app_name) built in Doka with the %(theme) theme.
```

In the Doka documentation app, this printed the following:

Welcome to %(app_name) built in Doka with the %(theme) theme.

You can also access nested configurations using the `.` notation. Suppose you have 
a configuration called `data` which is a list of fruit names, you'll access the 
first name with `%(data.0)`. This also applies to indexes in dictionaries &mdash; 
e.g. `%(data.name)` etc.

#### Escaping configuration in website

If your real intention is to write `%(data.0)` without extracting the configuration 
value, then you'll need to escape it by adding a `%` prefix. For example, `%%(data.0)` 
this will simply print the value  `%(data.0)`.

