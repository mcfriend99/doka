/**
 * Parse {.class #id key=val} strings
 * 
 * @param {string} str: string to parse
 * @param {number} start: where to start parsing (including {)
 * @returns {AttributePair[]}: [['key', 'val'], ['class', 'red']]
 */
def getAttrs(str, start) {
  # not tab, line feed, form feed, space, solidus, greater than sign, quotation mark, apostrophe and equals sign
  var allowedKeyChars = '/[^\t\n\f />"\'=]/'
  var pairSeparator = ' '
  var keySeparator = '='
  var classChar = '.'
  var idChar = '#'
  var attrs = []
  var key = ''
  var value = ''
  var parsingKey = true
  var valueInsideQuotes = false

  # read inside {}
  # start + left delimiter length to avoid beginning {
  # breaks when } is found or end of string
  iter var i = start + 1; i < str.length(); i++ {
    if str[i, i + 1] == '}' {
      if key != '' { 
        attrs.append([key, value]) 
      }
      break
    }

    var char_ = str[i]

    # switch to reading value if equal sign
    if char_ == keySeparator and parsingKey {
      parsingKey = false
      continue
    }

    # {.class} {..css-module}
    if char_ == classChar and key == '' {
      if i + 1 < str.length() -1 and str[i + 1] == classChar {
        key = 'css-module'
        i += 1
      } else {
        key = 'class'
      }
      
      parsingKey = false
      continue
    }

    # {#id}
    if char_ == idChar and key == '' {
      key = 'id'
      parsingKey = false
      continue
    }

    # {value="inside quotes"}
    if char_ == '"' and value == '' and !valueInsideQuotes {
      valueInsideQuotes = true
      continue
    }

    if char_ == '"' and valueInsideQuotes {
      valueInsideQuotes = false
      continue
    }

    # read next key/value pair
    if char_ == pairSeparator and !valueInsideQuotes {
      if key == '' {
        # beginning or ending space: { .red } vs {.red}
        continue
      }

      attrs.append([key, value])
      key = ''
      value = ''
      parsingKey = true
      continue
    }

    # continue if character not allowed
    if parsingKey and !char_.match(allowedKeyChars) {
      continue
    }

    # no other conditions met; append to key/value
    if parsingKey {
      key += char_
      continue
    }

    value += char_
  }

  return attrs
}

/**
 * Add attributes from [['key', 'val']] list.
 * 
 * @param {AttributePair[]} attrs: [['key', 'val']]
 * @param {Token} token: which token to add attributes
 * @returns token
 */
def addAttrs(attrs, token) {
  iter var j = 0; j < attrs.length(); j++ {
    var key = attrs[j][0]
    if key == 'class' {
      token.attr_join('class', attrs[j][1])
    } else if key == 'css-module' {
      token.attr_join('css-module', attrs[j][1])
    } else {
      token.attr_push(attrs[j])
    }
  }

  return token
}

/**
 * Does string have properly formatted curly?
 *
 * start: '{.a} asdf'
 * end: 'asdf {.a}'
 * only: '{.a}'
 *
 * @param {'start'|'end'|'only'} where to expect {} curly. start, end or only.
 * @return {DetectingStrRule} Function which testes if string has curly.
 */
def hasDelimiters(where) {

  if !where or !is_string(where) {
    raise Exception('Parameter `where` not passed. Should be "start", "end" or "only".')
  }

  /**
   * @param {string} str
   * @return {boolean}
   */
  return @(str) {
    # we need minimum three chars, for example {b}
    var minCurlyLength = 1 + 1 + 1
    if !str or !is_string(str) or str.length() < minCurlyLength {
      return false
    }

    /**
     * @param {string} curly
     */
    def validCurlyLength (curly) {
      var isClass = curly[1] == '.'
      var isId = curly[1] == '#'

      return (isClass or isId) ? 
        curly.length() >= (minCurlyLength + 1) : 
        curly.length() >= minCurlyLength
    }

    var start, end, slice, nextChar
    var rightDelimiterMinimumShift = minCurlyLength - 1

    using where {
      when 'start' {
        # first char should be {, } found in char 2 or more
        slice = str[,1]
        start = slice == '{' ? 0 : -1
        end = start == -1 ? -1 : str.index_of('}', rightDelimiterMinimumShift)

        # check if next character is not one of the delimiters
        nextChar = end + 1 < str.length() ? str[end + 1] : ''
        if nextChar == '}' {
          end = -1
        }
      }
      when 'end' {
        # last char should be }
        start = last_index_of(str, '{')
        end = start == -1 ? -1 : str.index_of('}', start + rightDelimiterMinimumShift)
        end = end == str.length() - 1 ? end : -1
      }
      when 'only' {
        # '{.a}'
        slice = str[,1]
        start = slice == '{' ? 0 : -1
        slice = str[str.length() - 1,]
        end = slice == '}' ? str.length() - 1 : -1
      }
      default {
        raise Exception("Unexpected case ${where}, expected 'start', 'end' or 'only'")
      }
    }

    return start != -1 and end != -1 and validCurlyLength(str[start, end + 1])
  }
}

/**
 * Removes last curly from string.
 * 
 * @param {string} str
 */
def removeDelimiter(str) {
  var curly = '/[ \\n]?\{[^\{\}]+\}$/'

  var pos = -1
  var tmp_seen = str.match(curly)
  if tmp_seen {
    pos = str.index_of(tmp_seen[0])
  }
  
  return pos != -1 ? str[,pos] : str
}

/**
 * Find corresponding opening block
 * 
 * @param {Token[]} tokens
 * @param {number} i
 */
def getMatchingOpeningToken(tokens, i) {
  if tokens[i].type == 'softbreak' {
    return false
  }

  # non closing blocks, example img
  if tokens[i].nesting == 0 {
    return tokens[i]
  }

  var level = tokens[i].level
  var type = tokens[i].type.replace('_close', '_open')
  iter ; i >= 0; i-- {
    if tokens[i].type == type and tokens[i].level == level {
      return tokens[i]
    }
  }

  return false
}

def last_index_of(str, delim) {
  if str.index_of(delim) > -1 {
    return delim.join(str.split(delim)[,-1]).length()
  } else {
    return -1
  }
}
