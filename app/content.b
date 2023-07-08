
import markdown
import highlight { highlight }
import .nav
import .toc_plugin { toc_plugin }
import .anchor_plugin { anchor_plugin }

var md = markdown({
  highlight: highlight(),
}).use(toc_plugin).use(anchor_plugin)

def get_template_vars(req, md_file, config) {
  return {
    navs: {
      main: nav.create_navigation(config.sitemap, req.path, config),
      subnav: nav.create_subnav(config.endpoints, req.path, config),
    },
    page: {
      content: md_file and is_file(md_file) ? md.render(md_file.read()) : md_file,
      title: nav.get_title(config.endpoints, req.path),
      next: nav.get_nth_endpoint(config.endpoints, req.path, 1),
      previous: nav.get_nth_endpoint(config.endpoints, req.path, -1),
    },
    config,
    theme: config.theme_config,
    theme_name: config.theme,
    doka: config.doka,
    request: is_dict(req) ? req : req.to_dict(),
  }
}
