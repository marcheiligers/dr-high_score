// FROM: https://gist.github.com/KonnorRogers/9ca86e4d055d81ee702fb79ceda5df20
// .dragonruby/stubs/html5/dragonruby-html5-loader.js
// ...
// end of dragonruby-html5-loader.js ...

// A silly hack for Safari browsers to get `window.open` to behave properly.
// The hack is fairly straightforward. We create a "hidden" anchor. When the user clicks on the page, if `window.open` gets called
// in a "click" event, it will set the `href` and `target` attributes on the anchor, and then when the `pointerup` finishes, reverts
// the override on `window.open` and remove the `href` and `target` attributes.
//
// As for "why" this works, Safari as part of "security", generally only expects `window.open` to be called in "click" and "click-like"
// IE: "pointer" events. So this is a funky hack to simulate a click for DragonRuby.

if (isSafari() || isMobileSafari()) {
  var anchor = document.createElement("a")
  // "visually-hidden" https://www.a11yproject.com/posts/how-to-hide-content/
  anchor.setAttribute("style", `
    clip: rect(0 0 0 0);
    clip-path: inset(50%);
    height: 1px;
    width: 1px;
    overflow: hidden;
    position: absolute;
    white-space: nowrap;
  `)
  anchor.removeAttribute("href")
  anchor.removeAttribute("target")
  anchor.textContent = "0"
  document.body.prepend(anchor)

  document.addEventListener("pointerup", (e) => {
    var originalOpen = window.open

    // Override the window.open function.
    window.open = function (url, target) {
      anchor.setAttribute("href", url)
      anchor.setAttribute("target", target)
    }
    setTimeout(() => {
      anchor.click()
      anchor.style.left = "0px"
      anchor.style.top = "0px"
      anchor.removeAttribute("href")
      anchor.removeAttribute("target")
      window.open = originalOpen
      // Not sure if 200 is optimal, but seems to work the best. May need to play around with it on mobile because touch events on mobile tend to take ~200-300ms.
    }, 200)
  })
}
