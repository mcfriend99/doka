
import markdown
import .highlight
import .nav
import .markdown_plugin.toc
import .markdown_plugin.vars
import .markdown_plugin.attrs

var md = markdown({
  highlight: highlight(),
  html: true,
}).use(toc).use(attrs)

def get_template_vars(req, md_file, meta, config) {
  md.use(@(md, options){  return vars(md, config) })
  var markdown =  md_file and is_file(md_file) ? md_file.read() : ''
  
  return {
    navs: {
      main: nav.create_navigation(config.sitemap, req.path, config),
      subnav: nav.create_subnav(config.endpoints, req.path, config),
    },
    page: {
      markdown,
      content: md_file and is_file(md_file) ? md.render(markdown) : md_file,
      title: nav.get_title(config.endpoints, req.path),
      next: nav.get_nth_endpoint(config.endpoints, req.path, 1),
      previous: nav.get_nth_endpoint(config.endpoints, req.path, -1),
      meta,
    },
    config,
    theme: config.theme_config,
    theme_name: config.theme,
    doka: config.doka,
    request: is_dict(req) ? req : req.to_json(),
  }
}
