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

    a.menu-icon-135,
    ul.links li.menu-icon-135 a,
    ul.menu li.menu-icon-135 a {
        background-image: url(https://naturefrance.fr/sites/default/files/menu_icons/EtatEvolution_0.svg);
        padding-left:px;
        background-repeat: no-repeat;
        background-position: left center;
    }
    a.menu-icon-136,
    ul.links li.menu-icon-136 a,
    ul.menu li.menu-icon-136 a {
        background-image: url(https://naturefrance.fr/sites/default/files/menu_icons/Pressions_Menaces.svg);
        padding-left:px;
        background-repeat: no-repeat;
        background-position: left center;
    }
    a.menu-icon-137,
    ul.links li.menu-icon-137 a,
    ul.menu li.menu-icon-137 a {
        background-image: url(https://naturefrance.fr/sites/default/files/menu_icons/Connaissance.svg);
        padding-left:px;
        background-repeat: no-repeat;
        background-position: left center;
    }
    a.menu-icon-138,
    ul.links li.menu-icon-138 a,
    ul.menu li.menu-icon-138 a {
        background-image: url(https://naturefrance.fr/sites/default/files/menu_icons/Politique.svg);
        padding-left:px;
        background-repeat: no-repeat;
        background-position: left center;
    }
    a.menu-icon-139,
    ul.links li.menu-icon-139 a,
    ul.menu li.menu-icon-139 a {
        background-image: url(https://naturefrance.fr/sites/default/files/menu_icons/Societe.svg);
        padding-left:px;
        background-repeat: no-repeat;
        background-position: left center;
    }
    a.menu-icon-140,
    ul.links li.menu-icon-140 a,
    ul.menu li.menu-icon-140 a {
        background-image: url(https://naturefrance.fr/sites/default/files/menu_icons/Economie_0.svg);
        padding-left:px;
        background-repeat: no-repeat;
        background-position: left center;
    }
    a.menu-icon-167,
    ul.links li.menu-icon-167 a,
    ul.menu li.menu-icon-167 a {
        background-image: url(https://naturefrance.fr/sites/default/files/menu_icons/Milieux_Forestiers.svg);
        padding-left:px;
        background-repeat: no-repeat;
        background-position: left center;
    }
    a.menu-icon-168,
    ul.links li.menu-icon-168 a,
    ul.menu li.menu-icon-168 a {
        background-image: url(https://naturefrance.fr/sites/default/files/menu_icons/Milieux_Aquatiques.svg);
        padding-left:px;
        background-repeat: no-repeat;
        background-position: left center;
    }
    a.menu-icon-170,
    ul.links li.menu-icon-170 a,
    ul.menu li.menu-icon-170 a {
        background-image: url(https://naturefrance.fr/sites/default/files/menu_icons/Milieux_Marins.svg);
        padding-left:px;
        background-repeat: no-repeat;
        background-position: left center;
    }
    a.menu-icon-171,
    ul.links li.menu-icon-171 a,
    ul.menu li.menu-icon-171 a {
        background-image: url(https://naturefrance.fr/sites/default/files/menu_icons/Milieux_Agricoles.svg);
        padding-left:px;
        background-repeat: no-repeat;
        background-position: left center;
    }
    a.menu-icon-172,
    ul.links li.menu-icon-172 a,
    ul.menu li.menu-icon-172 a {
        background-image: url(https://naturefrance.fr/sites/default/files/menu_icons/Milieux_Batis.svg);
        padding-left:px;
        background-repeat: no-repeat;
        background-position: left center;
    }
    a.menu-icon-192,
    ul.links li.menu-icon-192 a,
    ul.menu li.menu-icon-192 a {
        background-image: url(https://naturefrance.fr/sites/default/files/menu_icons/Milieux_Humides_0.svg);
        padding-left:px;
        background-repeat: no-repeat;
        background-position: left center;
    }

    `;

  class WCEmbeddedHeader extends HTMLElement {
    connectedCallback() {
      fetch(this.getAttribute('src'))
        .then(response => response.text())
        .then(html => {
          // replace all relative references (href, src)
          html = html.replaceAll('="/','="https://naturefrance.fr/')

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
  WCEmbeddedHeader
);

let sib_footer_style = document.createElement('style');
sib_footer_style.textContent = `
    .region--footer-top::before {
      position: unset !important;
    }
    .region--footer-top {
      margin: 0;
    }
    .region--footer-top .gn-credits {
      background-color: #2e8e47;
      padding: 10px 0 0 20px;
      font-style: italic;
      color: white;
    }
    .region--footer-bottom {
      position: relative;
    }
    `;

class WCEmbeddedFooter extends HTMLElement {
  connectedCallback() {
    fetch(this.getAttribute('src'))
      .then(response => response.text())
      .then(html => {
        // replace all relative references (href, src)
        html = html.replaceAll('="/','="https://naturefrance.fr/')

        const shadow = this.attachShadow({ mode: 'open'});
        shadow.innerHTML = html;

        // Add custom style (see above)
        shadow.appendChild(sib_footer_style);

        // Hide main content and footer (keep only header)
        const mainContent = this.shadowRoot.querySelector("main");
        if (typeof mainContent !== 'undefined') {
          mainContent.parentNode.removeChild(mainContent);
        }
        const headerContent = this.shadowRoot.querySelector("header");
        if (typeof headerContent !== 'undefined') {
          headerContent.parentNode.removeChild(headerContent);
        }
        const footerTopContent = this.shadowRoot.querySelector(".region--footer-top");
        if (typeof footerTopContent !== 'undefined') {
          footerTopContent.innerHTML='<div class="gn-credits">Propulsé par GeoNetwork 4</div>';
        }
      });
  }
}

window.customElements.define(
  'sib-footer',
  WCEmbeddedFooter
);
