# Styling and Layouts

A Doka site is a standard HTML/CSS website and unless your theme opts to do 
something different like using the React framework, styling your website 
should be a breeze so long as your theme supports it (which it should).

> **ATTENTION**
> 
> Since a theme decides a lot of what is stylable and configurable, a refresh 
> of this article is recommended for theme authors before embarking on their 
> journey of creating the perfect theme so as to stay consistent with the 
> ecosystem.

This article applies in general to all built-in themes and is expected be 
consistent with all themes in the ecosystem.

## Overriding Styles

Overriding website styling is actually very simple and your theme should tell 
give you all the information you need to know if there is any deviation.

To override CSS styling for your website, you need to create a new override 
file at `css/custom.css` in your [assets directory](/guides/assets) which should 
be at `assets/` by default (i.e. `assets/css/custom.css`).

Any CSS defined in the `css/custom.css` file should automatically override any 
defined by your theme.

## Including CSS frameworks

Most themes such as the default theme allows you to add extra stylesheets (CSS 
files) to your application thus allowing you to be able yo use your own CSS file 
as well as CSS frameworks. For instance, all built-in themes support the `styles` 
theme configuration that allows specifying a list of CSS files that should be 
included in the website.

For example, to include bootstrap in your application stylesheets you should add 
it to the styles application config like this.

```json5
{
  ...
  "styles": [
    "https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css",
    ...
  ]
  ...
}
```

> **NOTE**
>
> Support for this feature will depend on your theme if you are using a non 
> built-in theme. However, it is conventional for most themes to support this. 

> *Theme authors are encouraged to support this feature.*

## Styling the navigation

Since navigations are very important to websites and documentations, Doka allows 
both theme and application to style the navigation without theme authors having to 
lift a finger. For this reason all Doka themes automatically support styling of 
the navigation.

Navigation styling is achieved by overriding one or more of the following application 
configurations.

- **nav_class**: The CSS class applied to all `<ul>` elements in a navigation.
- **nav_item_class**: The CSS class applied to all `<li>` elements in a navigation.
- **nav_link_class**: The CSS class applied to all link (`<a>`) elements in a 
  navigation.
- **active_nav_class**: The extra CSS class applied only to the `<li>` navigation 
  element that represents the currently active page.

## Changing the page layout

Most themes support multiple kinds of layouts and you can change the layout of your page by following the instructions [here](/getting-started/sitemap#changing-the-page-type).

