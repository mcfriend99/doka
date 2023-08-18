import http
import os
import template
import .utils
import .functions
import .build
import .search

def serve(options) {
  if !os.dir_exists(options.root)
    die Exception('Invalid source directory!')

  var theme_path = os.join_paths(os.cwd(), 'themes', options.theme)
  if !os.dir_exists(theme_path) {
    theme_path = os.join_paths(
      os.dir_name(os.dir_name(__file__)), 
      'themes', options.theme
    )

    if !os.dir_exists(theme_path) {
      die Exception('Theme "${options.theme}" not found!')
    }
  }

  options.theme_directory = theme_path
  options.endpoints = utils.flatten_dict(options.sitemap)

  var tm = template()
  tm.set_root(theme_path)

  # register functions that can be reused by theme authors.
  tm.register_function('blank', functions.blank)
  tm.register_function('search_text', functions.search_query)

  var server = http.server(options.port, options.host)

  if !options.get('dev', false) {
    var final_sitemap = build(tm.render, options)

    server.on_receive(@(req, res) {
      if req.path != options.search_page {
        var path = final_sitemap.endpoints.get(req.path)
        if path {
          res.headers.extend(path.headers)
          res.write(path.content)
        } else {
          res.write(final_sitemap[404].content)
        }
      } else {
        search(req, res, tm.render, final_sitemap.endpoints, options)
      }
    })
  } else {
    server.on_receive(@(req, res) {
      var final_sitemap = build(tm.render, options)

      if req.path != options.search_page {
        var path = final_sitemap.endpoints.get(req.path)
        if path {
          res.headers.extend(path.headers)
          res.write(path.content)
        } else {
          res.write(final_sitemap[404].content)
        }
      } else {
        search(req, res, tm.render, final_sitemap.endpoints, options)
      }
    })
  }

  server.on_error(@(err, _) {
    echo err.message
    echo err.stacktrace
  })

  if options.host == '0.0.0.0' options.host = 'localhost'

  echo 'Server started on port http://${options.host}:${options.port}'
  server.listen()
}
