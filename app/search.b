import .utils
import .content
import .functions { search_query }
import markdown.core.anchor { slugify }
import os

def clean_string(string) {
  return string.replace('/\\n|\\r|\\t/', ' ').
                replace('/\s+/', ' ')
}

def de_regex(string) {
  return string.replace('/[$\[\]\\\\|.\\/+?(){}?^*]/', '\\$0')
}

def find(string, needle, content_path, content_title, result) {

  var clean_needle = de_regex(needle)

  def process(matches) {
    if matches {
      iter var i = 0; i < matches[0].length(); i++ {
        var is_intro = string.starts_with(matches[0][i])
  
        var title = is_intro ? content_title : content_title + ' &rsaquo; ' + matches[1][i]
        var url = is_intro ? content_path : content_path + '#' + slugify(matches[1][i])
        var excerpt = clean_string(
          matches[2][i].
            # replace links and images as they may cause repition
            replace('/\]\([^)]+\)/', '').
            # replace non-word characters
            replace('/[^\w\s"\']+/', '')[,200]

        # make the matched query itself bold
        ).replace('/(${clean_needle})/i', '<strong>$1</strong>')

        var existing_match = result.keys().filter(@(x) { 
          return excerpt.starts_with(x) or x.starts_with(excerpt) 
        })
        
        if existing_match {
          if existing_match[0].length() > excerpt.length() {
            continue
          } else {
            result.remove(existing_match[0])
          }
        }
        
        result.set(excerpt, {
          url,
          title,
          excerpt,
        })
      }
    }
  }

  # section match
  process(string.matches('/#{1,6} (.*${clean_needle}.*)\n+((.|\n(?!\n#{1,6} )(?!(\n#{1,6} )))*)/im'))

  # content match
  process(string.matches('/#{1,6} ([^\n]+)\n+((?:.|\n(?!\n#{1,6} ))*${clean_needle}(?:.|\n(?!\n#{1,6} ))*)/im'))
}

def do_search(query, sitemap) {

  # We'll be searching from the cache.
  var results = {}

  if query {
    # we'll only be searching through html files.
    var working_sitemap = sitemap.filter(@(map) {
      return map.file.ends_with('.html')
    })

    for path, data in working_sitemap {
      # we are using the md to avoid searching the entire html page 
      # which may include headers, sidebar and footers.
      find(
        data.md,
        clean_string(query),
        path,
        data.title,
        results
      )
    }
  }

  return results.to_list()[1]
}

def search(req, res, template, sitemap, options) {
  # allow the frontend to specify any name for the input in the search form.
  # pick the first input element submitted as the input name.
  # NB: It is already a requirement that, there should only be input in the 
  # request.
  var query = search_query(req.queries)

  var template_vars = content.get_template_vars(
    req, 
    do_search(query, sitemap),
    {description: '${query} - Search'},
    options
  )

  template_vars.page.title = query + ' - Search'

  res.write(template(
    'search.html', 
    template_vars
  ))
}
