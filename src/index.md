# Readable Sample

This is a demo site for Readable, generated as part of Sphinx Themes Gallery.

> **Important:** This sample documentation was generated on Jun 19, 2023, and is rebuilt weekly.

[[toc]]

## Quickstart

- Install this theme:
  
  ```
  $ pip install sphinx-readable-theme
  ```

- Set the following in your existing Sphinx documentation’s `conf.py` file:
  
  ```blade
  import sphinx_readable_theme
  var html_theme = 'readable'
  var html_theme_path = [sphinx_readable_theme.get_html_theme_path()]
  ```

- Build your Sphinx documentation with the new theme! [1](#quickstart)

## Documentation

This theme does not have any hosted-on-the-web documentation.

## Exploration

The [Kitchen Sink](/kitchen-sink) section contains pages that contains basically everything that you can with Sphinx “out-of-the-box”.

- Kitchen Sink
  - Admonitions
  - API documentation
  - Blocks
  - Generic items
  - Images & Figures
  - Lists
  - Really Long Page Title because we should test sidebar wrapping
  - Structural Elements
  - Structural Elements 2
  - Tables
  - Typography

Browsing through that section should give you a good idea of how stuff looks in this theme.

## Navigation

This is the most important part of a documentation theme. If you like the general look of the theme, please make sure that it is possible to easily navigate through this sample documentation.

Ideally, the pages listed below should also be reachable via links somewhere else on this page (like the sidebar, or a topbar). If they are not, then this theme might need additional configuration to provide the sort of site navigation that’s necessary for “real” documentation.

This is a caption

- Placeholder Page One
- Placeholder Page Two
- This is just a page with a really long title for checking how the theme handles these situations
- Long Page
- External Link

Some pages like Placeholder Page Three are declared in a “hidden” toctree, and thus would not be visible above. However, they are still a part of the overall site hierarchy and some themes may choose to present them to the user in the site navigation.

---

[1](#exploration) If you hit an error while building documentation with a new theme, it is likely due to some theme-specific configuration in the `conf.py` file of that documentation. These are usually `html_sidebars`, `html_theme_path` or `html_theme_config`. Unsetting those will likely allow the build to proceed.
