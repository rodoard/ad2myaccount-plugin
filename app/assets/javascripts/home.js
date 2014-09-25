function about() {
        var info = document.getElementById('about-content'),
            xhr;

        if (info.innerHTML === '') {
          xhr = new XMLHttpRequest();
          xhr.open("GET", "/rails/info/properties", false);
          xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
          xhr.send("");
          info.innerHTML = xhr.responseText;
        }

        info.style.display = info.style.display === 'none' ? 'block' : 'none';
      }