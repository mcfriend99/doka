document.addEventListener('DOMContentLoaded', function() {
  var codes = document.querySelectorAll('pre:has(> [class*=-repl])');
  codes.forEach(function(code) {
    code.addEventListener('click', function(e) {
      let bounds = code.getBoundingClientRect();
      let x = e.clientX - bounds.left;
      let y = e.clientY - bounds.top;

      if (y <= 20 && x >= bounds.width - 48) {
        if (code.classList.contains('off')) {
          code.classList.remove('off');
        } else {
          code.classList.add('off');
        }
      }
    }, false)
  })
})