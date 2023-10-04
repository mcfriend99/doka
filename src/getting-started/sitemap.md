# Sitemap

The _Sitemap_ is one of the most important and distinguishing feature of 
Doka as a configuration first system and they form the core of navigation 
between the pages of your application as well as provide page metadata.

By default, Doka makes no assumption on the navigation layout of your 
application and thus requires that all pages and links in the site navigation 
be defined in the sitemap file which can be found by default at 
`_data/sitemap.json`.

## The sitemap content

A Doka sitemap is simply an json object that is used to declare how to 
process different URL endpoints in the site. It is essentially a key-value pair 
where the key is the endpoint and the value is the endpoint metadata object.

Below is an example of the sitemap that is created for you when you create a 
new Doka application.

```json5
{
  "/": {
    "source": "index", 
    "title": "Home"
  }
}
```

The above sitemap declares when a user visits the home page (`/` endpoint), the 
site will be served from the file `src/index.md` and the title of the page will 
be **Home**.

> **NOTE**
>
> Did you notice that the `source` points to a file without an extension? That's 
> because the only recognized extension for source files are `.md` markdown files.

The `source` and `title` metadata are **the only required** metadata for a 
sitemap page. The `type` and `children` metadata are the other metadata with a 
reserved meaning and they are described below.

Every other metadata other the `source`, `title`, `children` and `type` will be 
passed on to the theme as is and what they mean may vary across themes. 

For example, the **default** theme allows specifying the `description` metadata 
which will be used to set the `description` for search engines crawling the page.

For example,

```json5
{
  "/my-page": {
    ...
    "description": "This is a great page."
  }
}
```

Will result in a webpage with the meta

```html
<meta name="description" content="This is a great page." />
```

in the `<head>` of the page when used with the default theme.

## Child pages (Nested navigation)

A sitemap page can contain linked child pages (submenu items) is by creating 
another sitemap in its `children` metadata. A child page is highly analogous to a 
nested sitemap. For example, to create a page hierrachy nested such as this one 
below,

```
|-- Page
|   |-- Sub Page 1
```

The sitemap will need to be nested as shown below:

```json5
{
  "/page": {
    "source": "/path/to/page/",
    "title": "Page",
    "children": {
      "/subpage1": {
        "source": "/path/to/subpage",
        "title": "Sub Page 1"
      }
    }
  }
}
```

Doka itself does not set a limit to how much nesting can be done, but a very generous 
limit will be 1024. If you find yourself having more than that number nested pages 
maybe Doka is not the right tool for your website.

## Changing the page type

Doka themes often come with a plethora of different page styles such as standard 
documentation pages, blog pages, information pages etc. The `type` metadata of a 
page entry allows you to specify the type of page that an endpoint should be 
rendered as.

For example,

```json5
{
  "/my-page": {
    ...
    "type": "blog",
    ...
  }
}
```

Despite themes being at the liberty of defining almost an infinite type of page 
designs, the page types below are a general requirement of all themes and will 
always be available as on option.

- **page**: The default documentation (or whatever it represents) page style for the theme. This will be used when the page type is not specified.

## Using different sitemaps

If you have a sitemap already declared in a file with another name or you have 
multiple sitemaps and will like to use a specific sitemap, you can change the 
sitemap used by overriding the default `sitemap` file in the application config 
file. 

For example,

```json5
{
  "app_name": "Dummy App",
  ...
  "sitemap": "/path/to/my/sitemap.json",
  ...
}
```

This can be very handle if for example you want to use different sitemaps for 
different domain or subdomains or simply want to use the same application to 
serve different websites.
