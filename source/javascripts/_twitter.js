window.App = window.App || {};

(function() {
  let twitterJSInstalled = false;

  // twitter's code:
  const installJS = function() {
    window.twttr = (function(d, s, id) {
    var js, fjs = d.getElementsByTagName(s)[0],
      t = window.twttr || {};
    if (d.getElementById(id)) return t;
    js = d.createElement(s);
    js.id = id;
    js.src = "https://platform.twitter.com/widgets.js";
    fjs.parentNode.insertBefore(js, fjs);

    t._e = [];
    t.ready = function(f) {
      t._e.push(f);
    };

    return t;
    }(document, "script", "twitter-wjs"));

    twitterJSInstalled = true;
  };

  const parseTweetURL = function(innerText) {
    const match = innerText.match(/^https:\/\/twitter.com\/\w+\/status\/(\d+)$/);
    if (!match) {
      return null;
    } else {
      return match[1];
    }
  };

  window.App.initializeTwitter = function() {
    // look for any <p> with tweet URLs and turn them into the embedded tweets.
    document.querySelectorAll('p').forEach(function(paragraph) {
      const tweetId = parseTweetURL(paragraph.innerText);

      if (tweetId) {
        // initialize twitter once
        if (!twitterJSInstalled) {
          installJS();
        }

        // create the tweet embed
        window.twttr.ready(function() {
          // twitter appends to the div, let's clear it out before it gets a chance to append
          paragraph.innerHTML = '';

          window.twttr.widgets.createTweet(tweetId, paragraph, {})
        });
      }
    });
  };
})();

