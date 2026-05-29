import url

def blank(value, alt) {
  if value return value
  return alt
}

def search_query(req) {
  if is_dict(req) {
    return url.decode(req.filter(@(_, q) {
      return ['q', 'query', 's', 'search'].contains(q.lower())
    }).reduce(@(init, value) {
      if init == '' init = value
      return init
    }, ''))
  }
  return ''
}
