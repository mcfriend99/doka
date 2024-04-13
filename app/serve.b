import http
import os
import json
import date
import .utils
import .functions
import .build
import .search

def log(req, res) {
  # echo '${date().format("c")} [${req.ip}] "${req.method} ${req.path} HTTP/${req.http_version}" "${req.headers.get("User-Agent")}" ${res.status} ${res.body.length()}'
  echo '${date().format("c")} [${req.ip}] "${req.method} ${req.path} HTTP/${req.http_version}" ${res.status} ${res.body.length()}'
}

def serve(options) {
  if !os.dir_exists(options.root)
    die Exception('Invalid source directory!')

  var tm = utils.init_template(options.theme_directory)
  var server = http.server(options.port, options.host)

  var silent = options.get('silent', false)
  var is_dev = options.get('dev', false)

  if !is_dev {
    var final_sitemap

    var cache_sitemap_file = file(os.join_paths(options.cache, '_sitemap.json'))
    if cache_sitemap_file.exists() {
      final_sitemap = json.parse(cache_sitemap_file.path())
    } else {
      final_sitemap = build(tm.render, options)
    }

    server.on_receive(@(req, res) {
      req.path = req.path.rtrim('/')
      
      if req.path != options.search_page {
        var path = final_sitemap.endpoints.get(req.path)
        if path {
          res.headers.extend(path.headers)

          # read on demand
          if !path.contains('content') {
            path.content = file(path.file).read()
          }

          res.write(path.content)
        } else {
          # read on demand
          var page_404 = final_sitemap['404']

          if !page_404.contains('content') {
            page_404.content = file(page_404.file).read()
          }

          res.write(page_404.content)
        }
      } else {
        search(req, res, tm.render, final_sitemap.endpoints, options)
      }

      if !silent log(req, res)
    })
  } else {
    server.on_receive(@(req, res) {
      if req.path != options.search_page {
        var final_sitemap = build(tm.render, options, req.path)

        var path = final_sitemap.endpoints.get(req.path)
        if path {
          res.headers.extend(path.headers)
          res.write(file(path.file).read())
        } else {
          res.write(file(final_sitemap['404'].file).read())
        }
      } else {
        var final_sitemap = build(tm.render, options)

        search(req, res, tm.render, final_sitemap.endpoints, options)
      }

      if !silent log(req, res)
    })
  }

  server.on_error(@(err, _) {
    echo err.message
    echo err.stacktrace
  })

  if options.host == '0.0.0.0' options.host = 'localhost'

  if !silent {
    echo (is_dev ? 'Development server' : 'Server') + ' started on port http://${options.host}:${options.port}'
  }
  server.listen()
}
