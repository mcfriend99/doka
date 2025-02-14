import .patterns_config
# import json

def attrs(md, _) {
  var patterns = patterns_config()

  /**
   * @param {StateCore} state
   */
  def curlyAttrs(state) {
    var tokens = state.tokens

    iter var i = 0; i < tokens.length(); i++ {
      iter var p = 0; p < patterns.length(); p++ {
        var pattern = patterns[p]

        var j = nil # position of child with offset 0
        var match = pattern.tests.every(@(t) {
          var res = test(tokens, i, t)
          if res.j != nil { 
            j = res.j
          }
          return res.match
        })

        if match {
          pattern.transform(tokens, i, j)
          if pattern.name == 'inline attributes' or pattern.name == 'inline nesting 0' {
            # retry, may be several inline attributes
            p--
          }
        }
      }
    }
  }

  md.core.ruler.before('linkify', 'curly_attributes', curlyAttrs)
}

/**
 * Test if t matches token stream.
 *
 * @param {Token[]} tokens
 * @param {number} i
 * @param {DetectingRule} t
 */
def test(tokens, i, t) {
  /** @type {MatchedResult} */
  var res = {
    match: false,
    j: nil  # position of child
  }
  
  var has_shift = t.contains('shift')
  var ii = has_shift ? i + t.shift : t.position

  if has_shift and ii < 0 {
    # we should never shift to negative indexes (rolling around to back of array)
    return res
  }

  var token
  catch {
    token = get(tokens, ii)  # supports negative ii
  } as token_error

  if token_error { return res; }
  var token_dict = token.to_dict()

  for key in t.keys() {
    if key == 'shift' or key == 'position' { continue }

    if !token_dict.contains(key) { 
      return res 
    }

    if key == 'children' and isArrayOfObjects(t.children) {
      if token.children.length() == 0 {
        return res
      }

      var match
      /** @type {DetectingRule[]} */
      var childTests = t.children
      /** @type {Token[]} */
      var children = token.children

      if childTests.every(@(tt) { return tt.contains('position') }) {
        # positions instead of shifts, do not loop all children
        match = childTests.every(@(tt) { 
          return test(children, tt.position, tt).match 
        })

        if match {
          # we may need position of child in transform
          var j = last(childTests).position
          res.j = j >= 0 ? j : children.length() + j
        }
      } else {
        iter var j = 0; j < children.length(); j++ {
          match = childTests.every(@(tt) {
            return test(children, j, tt).match
          })

          if match {
            res.j = j
            # all tests true, continue with next key of pattern t
            break
          }
        }
      }

      if match == false { 
        return res 
      }

      continue
    }

    var token_key = token_dict.get(key)
    using typeof(t[key]) {
      when 'boolean', 'number', 'string' {
        if token_key != t[key] { 
          return res 
        }
      }
      when 'function' {
        if !t[key](token_key) { return res; }
      }
      when 'dict' {
        if isArrayOfFns(t[key]) {
          var r = t[key].every(@(tt) { return tt(token_key) })
          if r == false { return res; }
        } else {
          raise Exception('Unknown type of pattern test (key: ${key}). Test should be of type boolean, number, string, function or array of functions.')
        }
      }
      # fall through for objects != arrays of defs
      default {
        raise Exception('Unknown type of pattern test (key: ${key}). Test should be of type boolean, number, string, function or array of functions.')
      }
    }
  }

  # no tests returned false -> all tests returns true
  res.match = true
  return res
}

def isArrayOfObjects(arr) {
  return is_list(arr) and arr.length() > 0 and arr.every(@(i) { 
    return is_dict(i) 
  })
}

def isArrayOfFns(arr) {
  return is_list(arr) and arr.length() > 0 and arr.every(@(i) { return is_function(i) })
}

/**
 * Get n item of array. Supports negative n, where -1 is last
 * element in array.
 * @param {Token[]} arr
 * @param {number} n
 * @returns {Token=}
 */
def get(arr, n) {
  return n >= 0 ? arr[n] : arr[arr.length() + n]
}

/**
 * get last element of array, safe - returns {} if not found
 * @param {DetectingRule[]} arr
 * @returns {DetectingRule}
 */
def last(arr) {
  return arr[-1] or {}
}
