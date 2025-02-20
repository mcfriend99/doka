document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('pre:has(> [class*=-repl])')
    ?.forEach(function(code) {
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

  let sidebar = document.getElementById('sidebar')

  document.getElementById('menutoggle')?.addEventListener('click', () => {
    if(sidebar) {
      if(sidebar.classList.contains('open')) {
        sidebar.classList.remove('open')
      } else {
        sidebar.classList.add('open')
      }
    }
  })

  document.querySelector('.content')?.addEventListener('click', () => {
    sidebar.classList.remove('open')
  })

  document.querySelectorAll('dt[id], h2[id]')?.forEach((el) => {
    el.addEventListener('click', () => {
      window.location.hash = el.getAttribute('id')
    })
  })
})
