/*
 * Create a WebComponent to embed the meun from naturefrance.fr
*/

// ref https://sebastiandedeyne.com/embed-a-web-page-with-a-web-component-and-the-shadow-dom/
  let style = document.createElement('style');
  style.textContent = `
    header {
      z-index: 1000;
      font-family: "Montserrat",sans-serif;
      font-size: 14px;
      font-weight: 400;
      line-height: 1.5;
      color: #000;
      text-align: left;
    }
    #menu--header {
      display: none;
    }
    .navbar-light .navbar-nav  #block-ofb-ui-search{
      visibility: hidden;
    }
    #header .region--header-top .navbar-brand img {
      width: 170px;
      height: 60px;
    }
    `;

  class EmbeddedWebview extends HTMLElement {
    connectedCallback() {
      fetch(this.getAttribute('src'))
        .then(response => response.text())
        .then(html => {
          const shadow = this.attachShadow({ mode: 'open'});
          shadow.innerHTML = html;

          // Add custom style (see above)
          shadow.appendChild(style);

          // Hide main content and footer (keep only header)
          const mainContent = this.shadowRoot.querySelector("main");
          if (typeof mainContent !== 'undefined') {
            mainContent.parentNode.removeChild(mainContent);
          }
          const footerContent = this.shadowRoot.querySelector("footer");
          if (typeof footerContent !== 'undefined') {
            footerContent.parentNode.removeChild(footerContent);
          }

          // Add menu interactions (javascript from imported DOM doesn't seem to respond)
          const menuButton = this.shadowRoot.querySelector(".menu--btn");
          const menuButtonIcon = this.shadowRoot.querySelector(".menu--btn button");
          const menuDiv = this.shadowRoot.querySelector("#menu--header");
          menuButton.addEventListener('click', function(e) {
            // console.log('clicked button');
            if (menuDiv.style.display !== "block") {
              menuDiv.style.display = "block";
              menuButtonIcon.setAttribute("aria-expanded", "true");
            } else {
              menuDiv.style.display = "none";
              menuButtonIcon.setAttribute("aria-expanded", "false");
            }
          });

          // Open partners page upon clickig the "Sites" button on the right
          const sitesButton = this.shadowRoot.querySelector("button.menu--nos-site");
          sitesButton.addEventListener('click', function(e) {
            window.open("https://naturefrance.fr/ressources-accessibles","_self");
          });
        });
    }
  }

  window.customElements.define(
    'sib-header',
    EmbeddedWebview
  );
