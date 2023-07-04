import http
import os
import template
import .utils
import .functions
import .build

# export this module outside this package
import .config

def serve(options) {
  if !os.dir_exists(options.root)
    die Exception('Invalid source directory!')

  var theme_path = os.join_paths(os.cwd(), 'templates', options.theme)
  if !os.dir_exists(theme_path) {
    theme_path = os.join_paths(
      os.dir_name(os.dir_name(__FILE__)), 
      'templates', options.theme
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

  var final_sitemap = build(tm.render, options)

  var server = http.server(options.port, options.host)
  server.on_receive(@(req, res) {
    if req.method.upper() == 'GET' {
      var path = final_sitemap.endpoints.get(req.path)
      if path {
        res.headers['Content-Type'] = path.mime
        res.write(path.file.read())
      } else {
        res.write(final_sitemap[404].file.read())
      }
      return
    }

    # handle search requests.
  })

  server.on_error(@(err, _) {
    echo err.message
    echo err.stacktrace
  })

  if options.host == '0.0.0.0' options.host = 'localhost'

  echo 'Server started on port http://${options.host}:${options.port}'
  server.listen()
}
