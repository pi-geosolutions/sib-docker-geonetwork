/*
 * Create a WebComponent to embed the menu from naturefrance.fr
*/

// ref https://sebastiandedeyne.com/embed-a-web-page-with-a-web-component-and-the-shadow-dom/
let sib_style = document.createElement('style');
sib_style.textContent = `
    header {
      z-index: 1000;
      font-family: "Marianne",sans-serif;
      font-size: 14px;
      font-weight: 400;
      line-height: 1.5;
      color: #000;
      text-align: left;
    }
    #menu--header {
      display: none;
    }
    .navbar-brand .search-block-form{
      visibility: hidden;
    }
    #header .region--header-top .navbar-brand img {
      //width: 170px;
      height: 60px;
    }
    .region--header {
      z-index: 9998;
    }
    .region--header-top .menu--btn__burger[aria-expanded="true"] .burger__bar:first-child {
      -webkit-transform: rotate(-45deg) translate(calc(-50% + 6px),-11px);
      transform: rotate(-45deg) translate(calc(-50% + 6px),-11px);
    }
`;

class WCEmbeddedHeader extends HTMLElement {
  connectedCallback() {
    fetch(this.getAttribute('src'))
      .then(response => response.text())
      .then(html => {
        // replace all relative references (href, src)
        html = html.replaceAll('="//','="https://')
        html = html.replaceAll('="/','="https://naturefrance.fr/')
        // console.log(html)
        const shadow = this.attachShadow({ mode: 'open'});
        shadow.innerHTML = html;

        // Add custom style (see above)
        shadow.appendChild(sib_style);

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
        const menuButtonBurger = this.shadowRoot.querySelector(".menu--btn__burger");
        const menuDiv = this.shadowRoot.querySelector("#menu--header");
        const menuBanner = this.shadowRoot.querySelector(".menu--banner");

        menuButton.addEventListener('click', function(e) {
          // console.log('clicked button');
          if (menuButtonBurger.getAttribute("aria-expanded") == "true") {
            menuButtonBurger.setAttribute("aria-expanded", "false")
            menuDiv.classList.remove("show");
            menuBanner.style.transform = "translateX(-100%)";
          } else {
            menuButtonBurger.setAttribute("aria-expanded", "true")
            menuDiv.classList.add("show");
            menuBanner.style.transform = "translateX(0)";
          }
        });
        // Hide the menu when user clicks outside in the modal part
        this.shadowRoot.querySelector(".menu--backdrop").addEventListener('click', function() {
          menuButtonBurger.ariaExpanded = "false";
          menuDiv.classList.remove("show");
          menuBanner.style.transform = "translateX(-100%)";
        });

        let shadowRoot = this.shadowRoot
        // dynamic behaviour of the menu sections
        let menuButtons = this.shadowRoot.querySelectorAll("#accordion-menu nav button.btn-link");
        // console.log("buttons");
        // console.log(menuButtons);
        menuButtons.forEach(function(item, index) {
          item.addEventListener('click', function () {
            // console.log("should open " + this.getAttribute('data-target'));
            const target_menu_id = this.getAttribute('data-target');

            // console.log("target menu block is " + target_menu_id);
            let menus = shadowRoot.querySelectorAll('#accordion-menu nav div.collapse');
            // console.log(menus);
            menus.forEach(function (item, index) {
              if (item.id != '#'+target_menu_id) {
                // console.log("should toggle out menu " + item.id);
                item.classList.remove("show");
                // item.setAttribute("aria-expanded", "false")
                // console.log("which now has classes " + item.classList);
              }
            });
            let target_menu = this.parentNode.querySelector(target_menu_id);
            target_menu.classList.add("show");
            target_menu.setAttribute("aria-expanded", "true")
          })
        });



        // Open partners page upon clicking the "Sites" button on the right
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
      padding:0;
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
        html = html.replaceAll('="//','="https://')
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
