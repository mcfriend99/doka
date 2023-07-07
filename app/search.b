import .utils
import .content
import .functions { search_query }
import os

def clean_string(string) {
  return string.replace('/<[^>]+>/', '').
                replace('/\\n|\\r|\\t/', ' ').
                replace('/\s+/', ' ')
}

def de_regex(string) {
  return string.replace('/[^$.|()\[\]-{}*+?\\/\\\\]/', '\\$0')
}

def find(string, needle, path, title, result) {
  var start_index = 0
  var index = -1

  var lowered_string = string.lower()
  var lowered_needle = needle.lower()
  while (index = lowered_string.index_of(lowered_needle, start_index)) != -1 {
    var start = index - 75 < 0 ? 0 : index - 75
    var end = index - 75 < 0 ? 150 - index : 75

    var excerpt = string[start, index + end].trim().replace('/(${de_regex(needle)})/i', '<strong>$1</strong>')
    
    result.set(excerpt, {
      path,
      title,
      excerpt,
    })

    start_index = index + needle.length()
  }
}

def do_search(query, sitemap) {

  # We'll be searching from the cache.
  var results = {}

  if query {
    # we'll only be searching through html files.
    var working_sitemap = sitemap.filter(@(map) {
      return map.file.path().ends_with('.html')
    })

    for path, data in working_sitemap {
      # we are using the md to avoid searching the entire html page 
      # which may include headers, sidebar and footers.
      find(
        clean_string(data.md),
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
    options
  )

  template_vars.page.title = query + ' - Search'

  res.write(template(
    'search.html', 
    template_vars
  ))
}
