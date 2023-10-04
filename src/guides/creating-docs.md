# Creating Docs

Creating a documentation page involves two easy steps:

1. Create a Markdown file with a `.md` extension any where in the `src` directory.
2. Add an entry in the sitemap for your desired URL and set the source metadata to 
   the path of the Markdown file.

For example,

Create a Markdown file called `greeting.md` and place it in the `src` directory.

```
|-- _data
|  |-- sitemap.json
|-- src
|  |-- greeting.md
|  ...
```

Enter some content in the `greeting.md` file such as,

```md
# Greetings from Doka

Create the perfect documentation for your open source project.

## Subheaders

look great when they are preceeded by two pounds (`##`).
```

Now we need to add a sitemap entry for it. Lets open the application sitemap (this 
should be `_data/sitemap.json` if you haven't overridden it) and add the following 
entries.

```json5
{
  ...
  "/hello": {
    "source": "greeting",
    "title": "Greetings from Doka"
  }
}
```

You can replace the `title` with anything you want; anything from the contents of 
the markdown you created earlier will look just great.

Now you can start your Doka application or restart it if it is already running.

If you reload your browser now, you should see a **Greetings from Doka** in the 
site navigation. Click it to see your new page.

> **Why did we have to restart whenever we add a new page?**
>
> 1. This is by design. While this may mean a little more work everytime we add 
> a new page to the site it greatly helps to prevent against lot of common 
> production issues and challenges such as navigation misalignment and unwanted 
> pages due to actions like merges, rebases and pull requests. Just imagine how 
> much trouble this will save you.
> 2. This is part of what helps Doka to achieve is amazing speed in production.
>
> Doka is built with production experience and performance first in mind.

