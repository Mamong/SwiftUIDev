// We're using a global variable to store the number of occurrences
var currSelected = -1;
var WKWebView_SearchResultCount = 0;

// helper function, recursively searches in elements and their child nodes
function WKWebView_HighlightAllOccurencesOfStringForElement(element, keyword) {
  if (element) {
    if (element.nodeType == 3) {
      // Text node
      while (true) {
        var value = element.nodeValue; // Search for keyword in text node
        var idx = value.toLowerCase().indexOf(keyword);

        if (idx < 0) break; // not found, abort

        var span = document.createElement("span");
        var text = document.createTextNode(value.substr(idx, keyword.length));
        span.appendChild(text);
        span.setAttribute("class", "WKWebView_Highlight");
        span.style.backgroundColor = "#C7C7CC";
        span.style.color = "black";
        text = document.createTextNode(value.substr(idx + keyword.length));
        element.deleteData(idx, value.length - idx);
        var next = element.nextSibling;
        element.parentNode.insertBefore(span, next);
        element.parentNode.insertBefore(text, next);
        element = text;
        WKWebView_SearchResultCount++; // update the counter
      }
    } else if (element.nodeType == 1) {
      // Element node
      if (
        element.style.display != "none" &&
        element.nodeName.toLowerCase() != "select"
      ) {
        for (var i = element.childNodes.length - 1; i >= 0; i--) {
          WKWebView_HighlightAllOccurencesOfStringForElement(
            element.childNodes[i],
            keyword
          );
        }
      }
    }
  }
}

function WKWebView_SearchNext() {
  WKWebView_jump(1);
}
function WKWebView_SearchPrev() {
  WKWebView_jump(-1);
}

function WKWebView_jump(increment) {
  prevSelected = currSelected;
  currSelected = currSelected + increment;

  if (currSelected < 0) {
    currSelected = WKWebView_SearchResultCount + currSelected;
  }

  if (currSelected >= WKWebView_SearchResultCount) {
    currSelected = currSelected - WKWebView_SearchResultCount;
  }

  prevEl = document.getElementsByClassName("WKWebView_Highlight")[prevSelected];

  if (prevEl) {
    prevEl.style.backgroundColor = "#C7C7CC";
  }
  el = document.getElementsByClassName("WKWebView_Highlight")[currSelected];
  el.style.backgroundColor = "yellow";

  el.scrollIntoView({ behavior: "smooth", block: "center" });
}

// the main entry point to start the search
function WKWebView_HighlightAllOccurencesOfString(keyword) {
  WKWebView_RemoveAllHighlights();
  WKWebView_HighlightAllOccurencesOfStringForElement(
    document.body,
    keyword.toLowerCase()
  );
}

// helper function, recursively removes the highlights in elements and their childs
function WKWebView_RemoveAllHighlightsForElement(element) {
  if (element) {
    if (element.nodeType == 1) {
      if (element.getAttribute("class") == "WKWebView_Highlight") {
        var text = element.removeChild(element.firstChild);
        element.parentNode.insertBefore(text, element);
        element.parentNode.removeChild(element);
        return true;
      } else {
        var normalize = false;
        for (var i = element.childNodes.length - 1; i >= 0; i--) {
          if (WKWebView_RemoveAllHighlightsForElement(element.childNodes[i])) {
            normalize = true;
          }
        }
        if (normalize) {
          element.normalize();
        }
      }
    }
  }
  return false;
}

// the main entry point to remove the highlights
function WKWebView_RemoveAllHighlights() {
  WKWebView_SearchResultCount = 0;
  currSelected = -1;

  WKWebView_RemoveAllHighlightsForElement(document.body);
}
