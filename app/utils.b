import json

def flatten_dict(items) {
  return items.reduce(@(data, item, key) {
    data.set(key, item)
    
    var children = item.get('children')
    if children {
      data.extend(flatten_dict(children))
    }

    return data
  }, {})
}
